json.extract! work_order,
              :work_order_id,
              :run_id,
              :customer_name,
              :customer_order_id,
              :load_time_kpi,
              :note_url,
              :powder_type,
              :product_code,
              :product_desc,
              :product_id,
              :product_serial,
              :unload_time_kpi,
              :white_powder,
              :component_batches,
              :component_colour,
              :special_instruct


if work_order[:wo_time]
  json.wo_time work_order[:wo_time]
end


if work_order[:grading]
  json.grading work_order[:grading]
end

if work_order[:finish_flag]
  json.finish_flag work_order[:finish_flag]
end

if work_order[:user_id]
  json.user_id work_order[:user_id]
end