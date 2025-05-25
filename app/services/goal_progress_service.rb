class GoalProgressService
  def self.check_single_goal(goal, year, month)
    target_month = "#{year}-#{month.to_s.rjust(2, '0')}"

    transactions = Transaction.where(goal_id: goal.id)
                              .where('DATE_FORMAT(transaction_date, "%Y-%m") = ?', target_month)

    total_paid = transactions.sum(:amount)

    status = total_paid >= goal.monthly_due_amount ? 'success' : 'failed'

    gms = GoalMonthlyStatus.find_or_initialize_by(goal_id: goal.id, month: target_month)
    gms.paid_amount = total_paid
    gms.status = status
    gms.save!
  end

  def self.check_all_goals_for_month(year, month)
    Goal.find_each do |goal|
      check_single_goal(goal, year, month)
    end
  end
end