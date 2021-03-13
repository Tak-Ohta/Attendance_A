class RenameMonthlyattendanceapprovalresultColumnToAttendances < ActiveRecord::Migration[5.1]
  def change
    rename_column :attendances, :monthlyattendanceapprovalresult, :monthly_attendance_approval_result
  end
end
