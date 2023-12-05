class GetRuns
  include ExtendedInteractor

  def call
    after_check do

      operation_record = Operation.find_by_operation_name("Get_Runs")
      message = {"wsdl:SessionID": context[:current_session],
                 "wsdl:cmdType": operation_record.operation_id,
                 "wsdl:cmdParams": {"arr:anyType": "{pArmID};" + context[:arm_id], attributes!: {
                     "arr:anyType": {"xsi:type": "xsd:string"}}}}


      result = Rails.cache.fetch("global-presentation/interactor/runs/getRuns/#{context[:arm_id]}") do
        ExecuteOperation.call(message: message)
      end
      if result.success? && !result.data.nil?
        context[:runs] = result.data
        context[:runs] = [context[:runs]] unless context[:runs].is_a?(Array)
        runs = []
        runs_till_date = context[:runs].select {|run_data| run_data if (Date.today - Date.parse(run_data[:start_date])).to_i >= 0}
        future_runs = context[:runs].select {|run_data| run_data if (Date.today - Date.parse(run_data[:start_date])).to_i < 0}
        future_runs = future_runs.length > 0 ? (future_runs.sort_by {|run_data| Date.parse(run_data[:start_date])}) : future_runs
        future_dates = future_runs.length > 0 ? future_runs.map {|run_data| run_data[:start_date]}.uniq : []
        future_runs = future_runs.length > 0 ? (future_runs.select {|run_data| run_data if ((future_dates.include?(run_data[:start_date])) && future_dates.find_index(run_data[:start_date]) < 10)}) : future_runs
        context[:runs] = runs_till_date.concat(future_runs)
        context[:runs].each do |run|
          run_record = Run.find_by(run_number: run[:run_number], arm_id: context[:arm_id], start_date: run[:start_date])
          product_record = Product.where(work_order_id: run[:work_order_id]).order(:updated_at).last
          run_count = context[:runs].select {|r| r[:run_number].eql?(run[:run_number]) && r[:arm_id].eql?(run[:arm_id]) && r[:start_date].eql?(run[:start_date])}.count
          mapProductDetails(product_record, run, run_record, run_count)
          run_record = Run.find_by(run_number: run[:run_number], arm_id: context[:arm_id], start_date: run[:start_date])
          if run_record
            result = GetTimers.call(id: run_record.id, entity: "Run", status: run_record.status)
            if result.success?
              run[:run_time] = result.time
            end
          end

          runs << run unless run[:run_number].nil? || (run[:finish_flag] && run[:status] == "unloaded")
        end
        context[:runs] = runs
      else
        context.fail!(message: result.message)
      end

    end
  end

  def check_context
    if context[:arm_id].nil?
      context.fail!(message: 'interactor.missing_details')
    end
  end


  def mapProductDetails(product_record, run, run_record, run_count)
    if product_record

      product_run_id = product_record.run_id
      no_of_products = Product.where(run_id: product_run_id).count
      if (context[:arm_type].nil?) && (run_record.nil? || !run_record.id.eql?(product_run_id))
        run_record = Run.find_or_create_by!(run_number: run[:run_number], arm_id: context[:arm_id], start_date: run[:start_date])
        run_record.status = product_record.status if run_count.eql?(1)
        run_record.save!
        entity_id = run_count.eql?(1) ? run_record.id : product_record.id
        entity_type = run_count.eql?(1) ? "Run" : "Product"
        timers = Timer.where(entity_id: product_record.run_id, entity_type: "Run")
        timers.each do |timer|
          if no_of_products.eql?(1)
            timer.assign_attributes(entity_id: entity_id, entity_type: entity_type)
            timer.save!
          else
            unless timer.start_time.to_s.blank?
              run_time = 0
              end_time = timer.end_time.to_s
              start_time = Time.parse(timer.start_time.to_s)
              if end_time.blank?
                timezone_offset = ((timer.start_time - timer.created_at) / 1.hour).round
                timezone_offset = sprintf("%+d", timezone_offset)
                end_time = Time.parse(Time.now.getlocal("#{timezone_offset}:00").strftime("%Y-%m-%d %H:%M:%S UTC").to_s)
              else
                end_time = Time.parse(end_time)
              end
              run_time += ((end_time > start_time) ? (end_time - start_time) : 0)
              if run_time > 0
                product_time = run_time / no_of_products
                product_end_time = timer.end_time.to_s.blank? ? nil : (timer.start_time + product_time)
                CreateOrUpdateTimer.call(entity: {id: entity_id, status: timer.status}, entity_type: entity_type, start_time: timer.start_time, end_time: product_end_time,created_at:timer.created_at)
                timer.end_time.to_s.blank? ? (timer.start_time += product_time) : (timer.end_time -= product_time)
                timer.created_at+=product_time if timer.end_time.to_s.blank?
                timer.save!
              end
            end
          end
        end
        product_record.run_id = run_record.id
        product_record.save!
        Run.find(product_run_id).destroy! if no_of_products.eql?(1)
      end

      if product_record.status && product_record.status.include?("loading") && product_record.user_id.nil? && context[:current_user]
        product_record.user_id = context[:current_user].id
        product_record.save!
      end
      run[:status] = product_record.status
      run[:user_id] = product_record.user_id
      run[:finish_flag] = product_record.finish_flag
      run[:grading] = product_record.grading unless product_record.grading.nil?
      status = product_record.run.status.nil? ? "loading" : product_record.status
      result = GetTimers.call(id: product_record.id, entity: "Product", status: status)
      if result.success?
        run[:wo_time] = result.time
      end
      product_data = ProductData.find_by(product_id: product_record.id)
      if product_data
        run[:load_data] = JSON.parse(product_data.load_data) unless product_data.load_data.nil?
        run[:unload_data] = JSON.parse(product_data.unload_data) unless product_data.unload_data.nil?
        run[:finish_data] = JSON.parse(product_data.finish_data) unless product_data.finish_data.nil?
        run[:fault_data] = JSON.parse(product_data.fault_data) unless product_data.fault_data.nil?
      end

    end
  end


end
