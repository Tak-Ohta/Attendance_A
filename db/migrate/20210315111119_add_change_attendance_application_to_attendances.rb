class AddChangeAttendanceApplicationToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :change_started_at, :datetime
    add_column :attendances, :change_finished_at, :datetime
    add_column :attendances, :re_change_started_at, :datetime
    add_column :attendances, :re_change_finished_at, :datetime
    add_column :attendances, :select_superior_for_attendance_change, :string
    add_column :attendances, :confirm_superior_for_attendance_change, :string
    add_column :attendances, :next_day_for_attendance_change, :boolean
    add_column :attendances, :check_box_for_attendance_change, :boolean
  end
end
