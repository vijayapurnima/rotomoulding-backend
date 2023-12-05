json.array!(@staff) do |member|
  json.partial! 'staff/staff', staff: member
end

