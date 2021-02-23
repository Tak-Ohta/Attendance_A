class AddBasicInfoToUsers < ActiveRecord::Migration[5.1]
  def change
    change_column :users, :basic_work_time, :datetime, default: Time.current.change(hour: 8, min: 0, sec: 0)
    change_column :users, :designated_work_start_time, :datetime, default: Time.current.change(hour: 9, min: 0, sec: 0)
    change_column :users, :designated_work_end_time, :datetime, default: Time.current.change(hour: 18, min: 0, sec: 0)
  end
end
