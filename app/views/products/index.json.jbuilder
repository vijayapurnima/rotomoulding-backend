json.array!(@products) do |product|
  json.partial! 'products/product', work_order: product

  if product[:arm_id]
    json.arm_id product[:arm_id]
  end

  if product[:load_data]
    json.load_data product[:load_data]
  end

  if product[:unload_data]
    json.unload_data product[:unload_data]
  end

  if product[:fault_data]
    json.fault_data product[:fault_data]
  end

  if product[:finish_data]
    json.finish_data product[:finish_data]
  end

end

