class SaveProductData
  include ExtendedInteractor

  def call
    after_check do
      run_record = Run.find_or_create_by!(arm_id: context[:product][:arm_id], run_number: context[:product][:run_number], start_date: context[:product][:start_date])
      product_record = Product.exists?(work_order_id: context[:product][:work_order_id])?(Product.where(work_order_id: context[:product][:work_order_id]).order(:updated_at).last):(Product.find_or_create_by!(work_order_id: context[:product][:work_order_id]))
      product_record.run_id = run_record.id
      if product_record && (product_record.finish_flag.nil? || (product_record.grading.nil? || !product_record.grading.eql?("Scrap")))
        if product_record.user_id.nil? || product_record.user_id == context[:current_user].id
          unless context[:product][:status].nil?
            product_record.status = context[:product][:status]
            product_record.save!
          end
          status = product_record.status
          status = product_record.status.split('_')[0].eql?("unloaded") ? "finishing" : product_record.status.split('_')[0] unless status.nil?
          if status && status.include?("ing")
            product_record.user_id = context[:current_user].id
            product_record.save!
          end
          unassigned_timer = Timer.where(entity_id: product_record.id, status: status, entity_type: "Product", end_time: nil)
          start_date = unassigned_timer.length > 0 ? (unassigned_timer.first.start_time) : (context[:product][:start_time])
          unless context[:product][:start_time].nil?
            CreateOrUpdateTimer.call(entity: {id: product_record.id, status: status}, entity_type: "Product", start_time: start_date, end_time: context[:product][:end_time])
          end

          product_data = ProductData.find_or_create_by!(product_id: product_record.id)
          product_data.assign_attributes(load_data: context[:product][:load_data].to_json) unless context[:product][:load_data].nil?
          product_data.assign_attributes(cook_data: context[:product][:cook_data].to_json) unless context[:product][:cook_data].nil?
          product_data.assign_attributes(cool_data: context[:product][:cool_data].to_json) unless context[:product][:cool_data].nil?
          product_data.assign_attributes(unload_data: context[:product][:unload_data].to_json) unless context[:product][:unload_data].nil?
          product_data.assign_attributes(finish_data: context[:product][:finish_data].to_json) unless context[:product][:finish_data].nil?
          product_data.assign_attributes(fault_data: context[:product][:fault_data].to_json) unless context[:product][:fault_data].nil?
          product_data.save!
          result = GetTimers.call(id: product_record.id, entity: "Product", status: status)
          if result.success?
            context[:product][:wo_time] = result.time
          end
        else
          context.fail!(message: "This product is currently being modified by another user")
        end
      else
        context.fail!(message: "This product is already finished")
      end
    end
  end

  def check_context
    if context[:product].nil?
      context.fail!(message: 'interactor.missing_details')
    end
  end
end