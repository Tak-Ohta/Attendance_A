class AddMonthlyAttendanceApprovalResultToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :monthly_attendance_approval_result, :string
  end
end
