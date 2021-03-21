class AddAttendancesChangeApprovalDayToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :attendances_change_approval_day, :datetime
  end
end
