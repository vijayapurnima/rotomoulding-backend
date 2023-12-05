class SetProductFinish
  include ExtendedInteractor

  def call
    after_check do
      operation_record = Operation.find_by_operation_name("Set_Product_Finish")
      run_record = Run.find_or_create_by!(run_number: context[:product][:run_number], arm_id: context[:product][:arm_id], start_date: context[:product][:start_date])
      product_record = Product.exists?(work_order_id: context[:product][:work_order_id])?(Product.where(work_order_id: context[:product][:work_order_id]).order(:updated_at).last):(Product.find_or_create_by!(work_order_id: context[:product][:work_order_id]))
      product_data = ProductData.find_or_create_by!(product_id: product_record.id)
      context[:product][:finish_data][:Finish_Time_Actual] = (context[:product][:finish_data][:Finish_Time_Actual].to_i || 0) / 1000
      product_data.assign_attributes(finish_data: context[:product][:finish_data].to_json)
      product_data.save!
      constructParams(context[:product])
      message = {"wsdl:SessionID": context[:current_session],
                 "wsdl:cmdType": operation_record.operation_id,
                 "wsdl:cmdParams": {"arr:anyType": context[:params], attributes!: {
                     "arr:anyType": {"xsi:type": "xsd:string"}}}}


      result = ExecuteOperation.call(message: message, noDataCall: true)
      if result.success?
        product_record.finish_flag = true
        product_record.user_id = nil
        product_record.save!
      else
        context.fail!(message: result.message)
      end
    end
  end

  def check_context
    if context[:product].nil?
      context.fail!(message: 'interactor.missing_details')
    end
  end


  def constructParams(product)
    context[:params] = []
    context[:params] << "{pWonum};" + product[:work_order_id].to_s
    product[:finish_data].each do |key, value|
      value = ((key.include?("Start_Time") || key.include?("End_Time")) && !value.blank?) ? (Time.parse(value).strftime("%d/%m/%Y %H:%M")) : (value.to_s)
      context[:params] << "{" + key + "}" + ';' + (value || '')
    end

  end
end