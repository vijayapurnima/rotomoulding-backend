class GetProducts
  include ExtendedInteractor

  def call
    after_check do

      operation_record = Operation.find_by_operation_name("Get_Product")
      message = {"wsdl:SessionID": context[:current_session],
                 "wsdl:cmdType": operation_record.operation_id,
                 "wsdl:cmdParams": {"arr:anyType": "{pWonum};" + context[:wo_id], attributes!: {
                     "arr:anyType": {"xsi:type": "xsd:string"}}}}


      result = Rails.cache.fetch("global-presentation/interactor/products/get_products/#{context[:wo_id]}", expires_in: 1.days) do
        ExecuteOperation.call(message: message)
      end
      if result.success?
        context[:products] = result.data
        context[:products] = [context[:products]] unless context[:products].is_a?(Array)
        context[:products].each do |product|
          product_record = Product.where(work_order_id: product[:work_order_id]).order(:updated_at).last
          run_record = Run.find(product_record.run_id)
          product[:arm_id] = run_record.arm_id
          product[:start_date]=run_record.start_date
          if product_record
            product[:finish_flag]=product_record.finish_flag
            product[:user_id]=product_record.user_id
            product[:grading]=product_record.grading unless product_record.grading.nil?
            status=(product_record.status.eql?("unloaded") && !product_record.finish_flag)?"finishing":product_record.status
            result = GetTimers.call(id: product_record.id, entity: "Product", status: status)
            if result.success?
              product[:wo_time] = result.time
            end
            product_data = ProductData.find_by(product_id: product_record.id)
            if product_data
              product[:load_data] = JSON.parse(product_data.load_data) unless product_data.load_data.nil?
              product[:unload_data] = JSON.parse(product_data.unload_data) unless product_data.unload_data.nil?
              product[:finish_data] = JSON.parse(product_data.finish_data) unless product_data.finish_data.nil?
              product[:fault_data] = JSON.parse(product_data.fault_data) unless product_data.fault_data.nil?
            end
          end
        end
      else
        context.fail!(message: result.message)
      end

    end
  end

  def check_context
    if context[:wo_id].nil?
      context.fail!(message: 'interactor.missing_details')
    end
  end
end