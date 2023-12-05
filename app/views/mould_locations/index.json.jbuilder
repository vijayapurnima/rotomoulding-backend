json.array!(@mould_locations) do |mould|
  json.partial! 'mould_locations/mould_location', mould_location: mould
end

