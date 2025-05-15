namespace :budget do
    desc "Notify users when their Budget's pay_due_date is today"
    task notify_due_today: :environment do
      today = Date.today
  
      budgets = Budget.where(pay_due_date: today, delete_flag: false)
  
      budgets.each do |budget|
        # Wallet-ийг эзэмшигчийг олно
        owner = budget.wallet.owner
  
        if owner
          Notification.create!(
            user_id: owner.id,
            title: "Budget Due Reminder",
            body: "Таны '#{budget.budget_name}' нэртэй Budget өнөөдөр дуусах гэж байна!",
            notification_type: "budget_due",
            read: false
          )
  
          puts "Notification sent to user #{owner.id} for Budget #{budget.budget_name}"
        end
      end
    end
  end