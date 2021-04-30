class AddChangeBeforeToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :change_before_started_at, :datetime
    add_column :attendances, :change_before_finished_at, :datetime
  end
end
