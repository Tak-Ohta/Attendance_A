class CreateAttendances < ActiveRecord::Migration[5.1]
  def change
    create_table :attendances do |t|
      t.date :worked_on
      t.datetime :started_at
      t.datetime :finished_at
      t.datetime :change_before_started_at
      t.datetime :change_before_finished_at
      t.string :note
      t.datetime :scheduled_end_time
      t.boolean :next_day_for_overtime
      t.string :instructor
      t.string :work_contents
      t.boolean :approval_check_box, default: false
      t.string :select_superior_for_overtime
      t.string :confirm_superior_for_overtime
      t.string :select_superior_for_monthly_attendance
      t.string :confirm_superior_for_monthly_attendance
      t.boolean :monthly_attendance_check_box, default: false
      t.string :monthly_attendance_approval_result
      t.string :select_superior_for_attendance_change
      t.string :confirm_superior_for_attendance_change
      t.boolean :next_day_for_attendance_change, default: false
      t.boolean :check_box_for_attendance_change, default: false
      t.string :instructor_for_attendances_change
      t.datetime :attendances_change_approval_day
      t.string :superior_for_attendance_log
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
