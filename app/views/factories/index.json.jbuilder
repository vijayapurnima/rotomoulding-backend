json.array!(@factories) do |factory|
  json.id factory[:factory_id]
  json.name factory[:factory_name]
end
