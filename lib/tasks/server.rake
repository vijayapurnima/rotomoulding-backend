task "start" => :environment do
  system 'rails server -p 6002'
end
