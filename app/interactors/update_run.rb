class UpdateRun
  include ExtendedInteractor

  def call
    after_check do
      run = Run.find(context[:id])

      timer_status = ""+((!run.status || run.status.include?("ed")) ? (context[:run][:status]) : (run.status))
      if timer_status.split("_")[0].include?("ed")
      timer_status=timer_status.sub('ed','ing')
      end
      unassigned_timer = Timer.where(entity_id: run.id, status: timer_status.split("_")[0], entity_type: "Run", end_time: nil)
      start_date = unassigned_timer.length > 0 ? (unassigned_timer.first.start_time) : (context[:run][:start_time])
      unless start_date.nil?
        CreateOrUpdateTimer.call(entity: {id: run.id, status: timer_status.split("_")[0]}, entity_type: "Run", start_time: start_date, end_time: context[:run][:end_time])
      end

      run.status = context[:run][:status]
      run.save!

      if context[:run][:products] && context[:run][:products].length > 0
        context[:run][:products].each do |product|
          CreateOrUpdateProduct.call(run_id: run.id, product: product, status: run.status, current_user: context[:current_user])
          if run.status.include?("cook") || run.status.include?("cool")
            product_record = Product.find_by(run_id: run.id, work_order_id: product[:work_order_id])
            constructProductData(product_record, run, start_date)
          end
        end
        if (run.status.include?("cook") || run.status.include?("cool")) && run.status.include?("ed")
          products = Product.where(run_id: run.id, status: run.status)
          if run.status.include?("cook")
            SetProductCook.call(current_session: context[:current_user].session_id, products: products)
          else
            SetProductCool.call(current_session: context[:current_user].session_id, products: products)
          end
        end
      end
      context[:run][:user_id] = Product.where(run_id: run.id).first.user_id
    end
  end

  def check_context
    if !Run.exists?(id: context[:id])
      context.fail!(message: 'interactor.not_exists')
    elsif context[:run].nil?
      context.fail!(message: 'interactor.missing_details')
    end
  end


  def constructProductData(product, run, start_date)
    stage = (run.status.include?("cook") ? "Cook" : "Cool")
    product_data = ProductData.find_by(product_id: product.id)
    data = (run.status.include?("cook") ? product_data.cook_data : product_data.cool_data) unless product_data.nil?
    data = (data) ? JSON.parse(data) : {}
    last_product = Product.where(run_id: run.id).order("updated_at").last
    if last_product
      data_record = ProductData.find_by(product_id: last_product.id)
      load_data = run.status.include?("cook") ? JSON.parse(data_record.load_data) : JSON.parse(data_record.cook_data) unless data_record.nil?
      operator = run.status.include?("cook") ? load_data["Load_Operator"] : load_data["Cook_Operator"] unless load_data.nil?
      date = run.status.include?("cook") ? load_data["Load_End_Time"].split(" ")[0] : load_data["Cook_End_Time"].split(" ")[0] unless load_data.nil?
      data[stage + "_Operator"] = operator if data[stage + "_Operator"].nil?
      data[stage + "_Date"] = date if data[stage + "_Date"].nil?

    end

    data[stage + "_Start_Time"] = start_date if data[stage + "_Start_Time"].nil?
    data[stage + "_End_Time"] = context[:run][:end_time] if data[stage + "_End_Time"].nil? && product.status.include?("ed")
    if data[stage + "_Time_Actual"].nil? && product.status.include?("ed")
      result = GetTimers.call(id: product.run_id, entity: "Run", status: stage.downcase! + "ing")
      if result.success?
        data[stage.capitalize! + "_Time_Actual"] = result.time / 1000
      end
    end
    product_object = {arm_id: run.arm_id, run_number: run.run_number, start_date: run.start_date, work_order_id: product.work_order_id}
    run.status.include?("cook") ? (product_object[:cook_data] = data) : (product_object[:cool_data] = data)
    SaveProductData.call(id: product.id, product: product_object, current_user: context[:current_user])
  end
end