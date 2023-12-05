namespace :data_reset do

  desc "Clears data in Runs,Products,Product_Data,Timers Tables"
  task clear: :environment do
    puts 'Clears data in the tables'
    time = Benchmark.realtime do
      timers_data=Timer.destroy_all
      runs_data=Run.destroy_all
    end
    puts "Finished clearing data related to runs and products including timers in #{(time / 60).floor} minutes and #{(time % 60).round(2)} seconds"
  end
end

