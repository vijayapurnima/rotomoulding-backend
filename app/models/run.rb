class Run < ApplicationRecord
  include AASM
  has_many :products, dependent: :destroy



  # aasm whiny_transitions: :false, column: 'status' do
  #   state :loading,initial: :true
  #   state :loading_paused
  #   state :cooking
  #   state :cooked
  #   state :cooling
  #   state :cooled
  #   state :unloading
  #   state :unloading_paused
  #
  #   event :activate do
  #     transitions from: :inactive, to: :active
  #   end
  #   event :deactivate do
  #     transitions from: :active, to: :inactive
  #   end
  #   event :deactivate do
  #     transitions from: :active, to: :inactive
  #   end
  #   event :deactivate do
  #     transitions from: :active, to: :inactive
  #   end
  #   event :deactivate do
  #     transitions from: :active, to: :inactive
  #   end
  #   event :deactivate do
  #     transitions from: :active, to: :inactive
  #   end
  #   event :deactivate do
  #     transitions from: :active, to: :inactive
  #   end
  #   event :deactivate do
  #     transitions from: :active, to: :inactive
  #   end
  # end

end