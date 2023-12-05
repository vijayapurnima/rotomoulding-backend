class CreateOrUpdateProduct
  include ExtendedInteractor

  def call
    after_check do
      product = Product.exists?(work_order_id: context[:product][:work_order_id])?(Product.where(work_order_id: context[:product][:work_order_id]).order(:updated_at).last):(Product.find_or_create_by!(work_order_id: context[:product][:work_order_id]))
      user_id = (context[:status].nil? || context[:status].include?("ed")) ? nil : context[:current_user].id
      product.assign_attributes(status: context[:status],
                                finish_flag: context[:product][:finish_flag],
                                grading: context[:product][:grading],
                                run_id: context[:run_id])
      product.user_id=user_id
      product.save!
    end
  end

  def check_context
    if context[:product].nil? || context[:run_id].nil?
      context.fail!(message: 'interactor.missing_details')
    end
  end
end