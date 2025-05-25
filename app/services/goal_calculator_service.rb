class GoalCalculatorService
    def self.calculate_monthly_due_amount(target_amount:, starting_amount:, start_date:, expected_date:)
      return 0 if target_amount.nil? || expected_date.nil?
  
      # Саруудад хөрвүүлж зөрүүг олно
      total_months = (expected_date.year * 12 + expected_date.month) - (start_date.year * 12 + start_date.month)
      total_months = [total_months, 1].max # Хамгийн багадаа 1 сар гэж үзнэ
  
      # Үлдсэн зорилтот дүн / үлдсэн сар
      ((target_amount - starting_amount) / total_months.to_f).ceil
    end
  end
  