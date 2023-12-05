class GetArms
  include ExtendedInteractor

  def call
    after_check do

      operation_record = Operation.find_by_operation_name("Get_Arms")
      message = {"wsdl:SessionID": context[:current_session],
                 "wsdl:cmdType": operation_record.operation_id,
                 "wsdl:cmdParams": {"arr:anyType": "{pOven};" + context[:oven_id], attributes!: {
                     "arr:anyType": {"xsi:type": "xsd:string"}}}}


      result = Rails.cache.fetch("global-presentation/interactor/arms/getArms/#{context[:oven_id]}") do
        ExecuteOperation.call(message: message)
      end
      if result.success?
        context[:arms] = result.data
        context[:arms] = [context[:arms]] unless context[:arms].is_a?(Array)
        finishing_ids = context[:arms].pluck(:finishing_id).uniq if context[:arms].length > 0
        finishing_ids = (finishing_ids && finishing_ids.length > 0) ? (finishing_ids.select {|finishing_id| finishing_id unless finishing_id.nil?}) : []
        finishing_list = getFinishingRuns(finishing_ids[0]) if finishing_ids.length > 0
        context[:arms].each do |arm|
          arm[:runs] = []
          arm[:finishing_list] = []
          getRuns(arm, arm[:arm_id])
        end
        if finishing_list && finishing_list.length > 0
          existing_runs = []
          finishing_list.each do |finishing_run|
            context[:arms].each do |arm|
              selected_runs_list = arm[:runs].select {|run_data| run_data if finishing_run[:work_order_id].eql?(run_data[:work_order_id])}
              selected_finishing_list = arm[:finishing_list].select {|finishing_data| finishing_data if finishing_run[:work_order_id].eql?(finishing_data[:work_order_id])}
              if selected_runs_list.length > 0 || selected_finishing_list.length > 0
                existing_runs << finishing_run
              end
            end
          end
          finishing_list -= existing_runs
        end
        if finishing_list && finishing_list.length > 0
          final_list = []
          finishing_list.each do |finishing_run|
            product_record = Product.find_by(work_order_id: finishing_run[:work_order_id], status: 'unloaded', finish_flag: nil)
            if product_record
              run_record = Run.find(product_record.run_id)
              finishing_run[:arm_id] = run_record.arm_id unless run_record.nil?
              final_list << finishing_run
            end
          end
          context[:arms][0][:finishing_list] += final_list
        end
      else
        context.fail!(message: result.message)
      end
    end
  end

  def check_context
    if context[:oven_id].nil?
      context.fail!(message: 'interactor.missing_details')
    end
  end

  def getFinishingRuns(arm_id)
    result2 = GetRuns.call(current_session: context[:current_session], arm_id: arm_id,arm_type:"finishing")
    if result2.success?
      runs = result2.runs
      runs = (runs.is_a?(Array)) ? runs : [runs]
    else
      []
    end
  end

  def getRuns(arm, arm_id)
    result2 = GetRuns.call(current_session: context[:current_session], arm_id: arm_id)
    if result2.success?
      runs = result2.runs
      runs = (runs.is_a?(Array)) ? runs : [runs]
      run_from_start_date = runs.collect {|run| run[:start_date].to_date if run.key? :start_date}.uniq.min
      runs.each do |run|
        flag = false
        run_record = Run.find_by(arm_id: arm[:arm_id], run_number: run[:run_number], start_date: run[:start_date])
        if run_record
          product_record = Product.where(work_order_id: run[:work_order_id]).order(:updated_at).last
          if product_record
            if product_record.status && product_record.status.include?("ed") && !product_record.user_id.nil? && product_record.user_id == context[:current_user].id
              product_record.user_id = nil
              product_record.save!
            end
            run[:status] = product_record.status
            run[:user_id] = product_record.user_id
            run[:run_status] = run_record.status
            run[:id] = run_record.id
            if run[:status].eql?("unloaded") || product_record.finish_flag.eql?(true)
              flag = true
              arm[:finishing_list] << run if !product_record.finish_flag && arm[:finishing_list].select {|run_data| run_data[:work_order_id] == run[:work_order_id]}.length == 0
            end
          end
        end
        if flag.eql?(false)
          (arm[:runs] << run) if arm[:runs].select {|run_data| run_data[:work_order_id] == run[:work_order_id]}.length == 0
        end
      end
    end

  end
end
