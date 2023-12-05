class ExecuteOperation
  include Interactor

  def call
    result = ExecuteQueryData.call(message: context[:message])

    if result.success?
      if (context[:noDataCall] != true)
        data_result = GetData.call(message: {"wsdl:SessionID": context[:message][:"wsdl:SessionID"]})
        if data_result.success?
          context[:data] = data_result.data
        else
          context.fail!(message: data_result.message)
        end
      end

    else
      result.success?
      context.fail!(message: result.message)
    end

  end
end
