class SetProductUnload
  include ExtendedInteractor

  def call
    after_check do
      failures = []
      operation_record = Operation.find_by_operation_name("Set_Product_Unload")
      run_record = Run.find_or_create_by!(run_number: context[:products][0][:run_number], arm_id: context[:products][0][:arm_id], start_date: context[:products][0][:start_date])
      context[:products].each do |product|
        product_record = Product.exists?(work_order_id: product[:work_order_id])?(Product.where(work_order_id: product[:work_order_id]).order(:updated_at).last):(Product.find_or_create_by!(work_order_id: product[:work_order_id]))
        product_data = ProductData.find_or_create_by!(product_id: product_record.id)
        product[:unload_data][:Unload_Time_Actual] = (product[:unload_data][:Unload_Time_Actual].to_i || 0) / 1000
        product_data.assign_attributes(unload_data: product[:unload_data].to_json)
        product_data.save!
        constructParams(product)
        message = {"wsdl:SessionID": context[:current_session],
                   "wsdl:cmdType": operation_record.operation_id,
                   "wsdl:cmdParams": {"arr:anyType": context[:params], attributes!: {
                       "arr:anyType": {"xsi:type": "xsd:string"}}}}



        result = ExecuteOperation.call(message: message, noDataCall: true)
        if result.success?
          product_record.status = "unloaded"
          product_record.user_id = nil
          product_record.save!
        else
          failures << {work_order_id: product[:work_order_id], message: result.message}
        end
      end
      if failures.length == 0 && Product.where(run_id: run_record.id, status: "unloaded").length == Product.where(run_id: run_record.id).length
        if Timer.exists?(entity_id:run_record.id,entity_type:"Run",status:"unloading",end_time:nil)
          timer=Timer.find_by(entity_id:run_record.id,entity_type:"Run",status:"unloading",end_time:nil)
          timezone_offset= ((timer.start_time - timer.created_at)/1.hour).round
          timezone_offset=sprintf("%+d", timezone_offset)
          timer.assign_attributes(end_time: Time.now.getlocal("#{timezone_offset}:00").strftime("%Y-%m-%d %H:%M:%S.%3N").to_s)
          timer.save!
        end
        run_record.status = "unloaded"
        run_record.save!
      end
      context[:failures] = failures
    end
  end

  def check_context
    if context[:products].nil?
      context.fail!(message: 'interactor.missing_details')
    end
  end


  def constructParams(product)
    context[:params] = []
    context[:params] << "{pWonum};" + product[:work_order_id].to_s
    product[:unload_data].each do |key, value|
      value = ((key.include?("Start_Time") || key.include?("End_Time")) && !value.blank?) ? (Time.parse(value).strftime("%d/%m/%Y %H:%M")) : (value.to_s)
      context[:params] << "{" + key + "}" + ';' + (value || '')
    end

  end
end
