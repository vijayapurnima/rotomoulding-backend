namespace :user_session do

  desc "create a  initial user to access accentis with session Id"
  task create: :environment do
    puts 'creating user with details'
    time = Benchmark.realtime do
    user_session=UserSession.find_or_create_by!(user_name:"Global")
      user_session.save!
    end
    puts "Finished creating user_seesion in #{(time / 60).floor} minutes and #{(time % 60).round(2)} seconds"
  end
end

