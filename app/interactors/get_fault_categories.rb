class GetFaultCategories
  include Interactor

  def call
    operation_record = Operation.find_by_operation_name("Get_Fault_Categories")
    message = {"wsdl:SessionID": context[:current_session], "wsdl:cmdType": operation_record.operation_id}

    result = ExecuteOperation.call(message: message)
    if result.success?
      context[:fault_categories] = result.data
    else
      context.fail!(message: result.message)
    end

  end
end
