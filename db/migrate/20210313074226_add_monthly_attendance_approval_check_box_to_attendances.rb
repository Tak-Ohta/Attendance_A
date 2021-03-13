class AddMonthlyAttendanceApprovalCheckBoxToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :monthly_attendance_check_box, :boolean
  end
end
