class Product < ApplicationRecord
  belongs_to :run
  has_one :product_data,dependent: :destroy


  def load_data
    unless self.product_data.nil?
      return self.product_data.load_data
    end
  end

  def unload_data
    unless self.product_data.nil?
      return self.product_data.unload_data
    end
  end

  def finish_data
    unless self.product_data.nil?
      return self.product_data.finish_data
    end
  end

  def fault_data
    unless self.product_data.nil?
      return self.product_data.fault_data
    end
  end

end