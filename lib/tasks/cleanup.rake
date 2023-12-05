namespace :cleanup do

  def user_session 
    @user_session ||= CreateLogin.call(
      username: ENV.fetch('ACCE_SERVICE_USER', ''), 
      password: ENV.fetch('ACCE_SERVICE_PASSWORD', '')
    ).user_session 
  end

  def factories 
    @factories ||= GetFactories
    .call(current_session: user_session.session_id)
    .factories
    .collect {|factory| factory[:factory_id]}
  end


  def ovens 
    @ovens ||= begin
      factory_ovens = []
      factories.each do |factory|
        factory_ovens << GetOvens
        .call(current_session: user_session.session_id, factory_id: factory)
        .ovens
        .collect {|oven| oven[:oven_id]}
      end
      factory_ovens.flatten      
    end
  end

  def arm_operation_record
    @arm_operation_record ||= Operation.find_by_operation_name("Get_Arms")
  end

  def get_arms(oven_id)
    message = {"wsdl:SessionID": user_session.session_id,
      "wsdl:cmdType": arm_operation_record.operation_id,
      "wsdl:cmdParams": {"arr:anyType": "{pOven};" + oven_id, attributes!: {
      "arr:anyType": {"xsi:type": "xsd:string"}}}}
    results = ExecuteOperation.call(message: message)
    if results.success?
      arm = results.data
      arm.is_a?(Array) ? arm.collect {|arm| arm[:arm_id]} : arm[:arm_id]
    else
      nil
    end
  end

  def arms 
    @arms ||= begin
      all_arms = []
      ovens.each do |oven|
        all_arms << get_arms(oven)
      end
      all_arms.flatten
    end
  end

  def run_operation_record 
    @run_operation_record ||= Operation.find_by_operation_name("Get_Runs")
  end

  def get_runs(arm_id)
    message = {"wsdl:SessionID": user_session.session_id,
      "wsdl:cmdType": run_operation_record.operation_id,
      "wsdl:cmdParams": {"arr:anyType": "{pArmID};" + arm_id, attributes!: {
      "arr:anyType": {"xsi:type": "xsd:string"}}}}
      
    result = ExecuteOperation.call(message: message)
    if result.success? && !result.data.nil?
      runs = result.data
      runs.is_a?(Array) ? runs.collect {|run| run[:work_order_id]} : runs[:work_order_id]
    else
      nil
    end
  end


  def work_order_ids 
    @work_order_ids ||= begin
      all_runs = []
      arms.each do |arm|
        all_runs << get_runs(arm)
      end
      all_runs.flatten
    end

  end

  
  desc "Cleans up Database of all data"
  task all: :environment do
    accentis_work_order_ids = work_order_ids

    delete_products_ids     = Product.where.not(work_order_id: accentis_work_order_ids).pluck(:id)
    delete_product_data_ids = ProductData.where(product_id:    delete_products_ids).pluck(:id)
    delete_runs_ids         = Product.where(id:                delete_products_ids).pluck(:run_id).uniq

    # Delete Timers First
    Timer.where(entity_id: delete_products_ids, entity_type:'Product').delete_all
    Timer.where(entity_id: delete_runs_ids    , entity_type:'Run').delete_all
    

    # Delete ProductsData -> Product -> Runs in that order to prevent foreign key execeptions
    ProductData.where(id: delete_product_data_ids).delete_all
    Product.where(id: delete_products_ids).delete_all

    run_ids = Product.all.pluck(:run_id)
    Run.where.not(id: run_ids).delete_all

  end

end
