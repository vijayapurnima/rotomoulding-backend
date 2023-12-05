json.extract! product,
              :work_order_id,
              :component_colour,
              :customer_name,
              :customer_order_id,
              :load_time_kpi,
              :mould_change,
              :note_url,
              :powder_type,
              :product_code,
              :product_desc,
              :product_id,
              :product_serial,
              :run_number,
              :start_date,
              :unload_time_kpi,
              :white_powder,
              :shot_weight,
              :component_batches,
              :special_instruct

if product[:finish_flag]
  json.finish_flag product[:finish_flag]
end

if product[:grading]
  json.grading product[:grading]
end


if product[:status]
  json.status product[:status]
end


if product[:run_status]
  json.run_status product[:run_status]
end


if product[:id]
  json.id product[:id]
end

if product[:run_time]
  json.run_time product[:run_time]
end

if product[:wo_time]
  json.wo_time product[:wo_time]
end

if product[:user_id]
  json.user_id product[:user_id]
end


if product[:start_date]
  json.run_date product[:start_date].to_date
end


if product[:load_data]
  json.load_data product[:load_data]
end