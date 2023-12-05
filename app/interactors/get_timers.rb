class GetTimers
  include Interactor

  def call
    if !context[:status].nil? && context[:status].include?("ing")
      time = 0
      timers = Timer.where(entity_id: context[:id], entity_type: context[:entity], status: context[:status].split('_')[0])
      if timers.length > 0
        timers.each do |timer|
          unless timer.start_time.to_s.blank?
            end_time = timer.end_time.to_s
            start_time = Time.parse(timer.start_time.to_s)
            if end_time.blank?
              timezone_offset= ((timer.start_time - timer.created_at)/1.hour).round
              timezone_offset=sprintf("%+d", timezone_offset)
              end_time = Time.parse(Time.now.getlocal("#{timezone_offset}:00").strftime("%Y-%m-%d %H:%M:%S UTC").to_s)
            else
              end_time = Time.parse(end_time)
            end
            time = time + (((end_time > start_time) ? (end_time - start_time) : 0) * 1000)
          end
        end

      end
      context[:time] = time
    end
  end
end
