set :output, "log/cron_log.log"

every 1.month, at: 'start of the month at 12am' do
  rake "transactions:insert_recurring"
end
