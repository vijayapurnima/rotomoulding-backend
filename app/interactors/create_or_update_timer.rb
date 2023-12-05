class CreateOrUpdateTimer
  include ExtendedInteractor

  def call
    after_check do
      timer = Timer.find_or_create_by!(entity_id: context[:entity][:id], entity_type: context[:entity_type], status: context[:entity][:status], start_time: context[:start_time])
      timer.assign_attributes(end_time: context[:end_time].to_s)
      timer.assign_attributes(created_at: context[:created_at]) unless context[:created_at].nil?
      timer.save!
    end
  end

  def check_context
    if context[:entity].nil? || context[:entity_type].nil?
      context.fail!(message: 'interactor.missing_details')
    end
  end
end