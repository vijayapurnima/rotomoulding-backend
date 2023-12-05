json.array!(@runs.sort_by {|run| run[:run_number]}) do |run|
  json.partial! 'runs/run', product: run
end

