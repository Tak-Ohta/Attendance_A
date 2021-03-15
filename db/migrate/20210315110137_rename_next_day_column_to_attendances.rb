class RenameNextDayColumnToAttendances < ActiveRecord::Migration[5.1]
  def change
    rename_column :attendances, :next_day, :next_day_for_overtime
  end
end
