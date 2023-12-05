class GetOperations
  include Interactor

  def call
    message = {"wsdl:SessionID": context[:current_session],
               "wsdl:cmdType": SystemConfig.get('accentis/master_id')}

    result = ExecuteOperation.call(client: context[:client], message: message)
    if result.success?
      context[:data] = result.data
      result.data.each do |operation|
        operationObj = Operation.find_or_create_by!(operation_name: operation[:mm_name])
        operationObj.assign_attributes(operation_id: operation[:mm_search_id])
        operationObj.save!
      end
    else
      context.fail!(message: result.message)
    end
  end
end
