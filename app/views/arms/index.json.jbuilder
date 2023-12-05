json.array!(@arms) do |arm|
  json.id arm[:arm_id]
  json.name arm[:arm_name]
  json.finishing_id arm[:finishing_id]
  json.finishing_list arm[:finishing_list]
  json.runs do
      json.array!(arm[:runs]) do |run|
        json.partial! 'runs/run', product: run
      end
  end
end
