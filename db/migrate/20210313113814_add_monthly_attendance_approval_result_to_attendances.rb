class AddMonthlyAttendanceApprovalResultToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :monthlyattendanceapprovalresult, :string
  end
end
