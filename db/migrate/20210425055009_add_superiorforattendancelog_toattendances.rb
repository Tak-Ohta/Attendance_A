class AddSuperiorforattendancelogToattendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :superior_for_attendance_log, :string
  end
end
