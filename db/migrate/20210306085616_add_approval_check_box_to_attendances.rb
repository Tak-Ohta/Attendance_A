class AddApprovalCheckBoxToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :approval_check_box, :boolean, default: false
  end
end
