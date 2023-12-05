class CreateRun
  include ExtendedInteractor

  def call
    after_check do
      run = Run.find_or_create_by!(run_number: context[:run][:run_number],
                                   arm_id: context[:run][:arm_id],
                                   start_date: context[:run][:start_date])

      run.assign_attributes(status: context[:run][:status])
      run.save!
      if context[:run][:products] && context[:run][:products].length > 0
        context[:run][:products].each do |product|
          CreateOrUpdateProduct.call(run_id: run.id, product: product, status: run.status, current_user: context[:current_user])
        end
      end
      CreateOrUpdateTimer.call(entity: run, entity_type: "Run", start_time: context[:run][:start_time])
      context[:run][:id] = run.id
      context[:run][:user_id] = Product.where(run_id:run.id).first.user_id
    end
  end

  def check_context
    if context[:run].nil?
      context.fail!(message: 'interactor.missing_details')
    end
  end
end