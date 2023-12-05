json.array!(@ovens) do |oven|
  json.id oven[:oven_id]
  json.name oven[:oven_name]
end
