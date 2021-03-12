class AddMonthlyAttendanceToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :select_superior_for_monthly_attendance, :string
    add_column :attendances, :confirm_superior_for_monthly_attendance, :string
  end
end
