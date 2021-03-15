class AddInstructorForAttendancesChangeToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :instructor_for_attendances_change, :string
  end
end
