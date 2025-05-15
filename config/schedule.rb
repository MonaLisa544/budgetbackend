set :output, "log/cron_log.log"

every 1.month, at: 'start of the month at 12am' do
  rake "transactions:insert_recurring"
end

every 1.day, at: '9:00 am' do
  rake "budget:notify_due_today"
end

every '0 0 1 * *' do
  rake "monthly_budget:auto_create"
end