class GetOvens
  include ExtendedInteractor

  def call
    after_check do

      operation_record = Operation.find_by_operation_name("Get_Ovens")
      message = {"wsdl:SessionID": context[:current_session],
                 "wsdl:cmdType": operation_record.operation_id,
                 "wsdl:cmdParams": {"arr:anyType": "{pFactory};" + context[:factory_id], attributes!: {
                     "arr:anyType": {"xsi:type": "xsd:string"}}}}


      result = ExecuteOperation.call(message: message)
      if result.success?
        context[:ovens] = result.data
      else
        context.fail!(message: result.message)
      end

    end
  end

  def check_context
    if context[:factory_id].nil?
      context.fail!(message: 'interactor.missing_details')
    end
  end
end
