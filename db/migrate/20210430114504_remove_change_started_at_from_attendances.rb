class RemoveChangeStartedAtFromAttendances < ActiveRecord::Migration[5.1]
  def change
    remove_column :attendances, :change_started_at, :datetime
    remove_column :attendances, :change_finished_at, :datetime
    remove_column :attendances, :started_at, :datetime
    remove_column :attendances, :finished_at, :datetime
  end
end
