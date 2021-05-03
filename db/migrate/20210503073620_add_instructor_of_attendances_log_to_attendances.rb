class AddInstructorOfAttendancesLogToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :instructor_of_attendances_log, :string
  end
end
