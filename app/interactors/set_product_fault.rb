class SetProductFault
  include ExtendedInteractor

  def call
    after_check do
      operation_record = Operation.find_by_operation_name("Set_Faults")
      run_record = Run.find_or_create_by!(run_number: context[:product][:run_number], arm_id: context[:product][:arm_id], start_date: context[:product][:start_date])
      product_record = Product.exists?(work_order_id: context[:product][:work_order_id])?(Product.where(work_order_id: context[:product][:work_order_id]).order(:updated_at).last):(Product.find_or_create_by!(work_order_id: context[:product][:work_order_id]))
      product_data = ProductData.find_or_create_by!(product_id: product_record.id)
      product_data.assign_attributes(fault_data: context[:product][:fault_data].to_json)
      product_data.save!
      constructParams(context[:product])
      message = {"wsdl:SessionID": context[:current_session],
                 "wsdl:cmdType": operation_record.operation_id,
                 "wsdl:cmdParams": {"arr:anyType": context[:params], attributes!: {
                     "arr:anyType": {"xsi:type": "xsd:string"}}}}


      result = ExecuteOperation.call(message: message, noDataCall: true)
      if result.success?
        if context[:product][:fault_data][:Fault_Grading].eql?("Scrap")
          product_record.finish_flag = true
          product_record.user_id = nil
        end
        product_record.grading = context[:product][:fault_data][:Fault_Grading]
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
    product[:fault_data].each do |key, value|
      context[:params] << "{" + key + "}" + ';' + (value.to_s || '')
    end

  end
end