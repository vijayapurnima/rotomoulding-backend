class SetProductCool
  include ExtendedInteractor

  def call
    after_check do
      failures = []
      operation_record = Operation.find_by_operation_name("Set_Product_Cool")
      context[:products].each do |product|
        product_data = ProductData.find_by(product_id: product.id)
        constructParams(product, product_data.cool_data)
        message = {"wsdl:SessionID": context[:current_session],
                   "wsdl:cmdType": operation_record.operation_id,
                   "wsdl:cmdParams": {"arr:anyType": context[:params], attributes!: {
                       "arr:anyType": {"xsi:type": "xsd:string"}}}}

        result = ExecuteOperation.call(message: message, noDataCall: true)
        unless result.success?
          failures << {work_order_id: product[:work_order_id], message: result.message}
        end
      end
      context[:failures] = failures
    end
  end

  def check_context
    if context[:products].nil?
      context.fail!(message: 'interactor.missing_details')
    end
  end

  def constructParams(product, cool_data)
    context[:params] = []
    context[:params] << "{pWonum};" + product.work_order_id.to_s
    cool_data = JSON.parse(cool_data)
    cool_data.each do |key, value|
      value = ((key.include?("Start_Time") || key.include?("End_Time")) && !value.blank?) ? (Time.parse(value).strftime("%d/%m/%Y %H:%M")) : (value.to_s)
      context[:params] << "{" + key + "}" + ';' + (value || '')
    end

  end

end