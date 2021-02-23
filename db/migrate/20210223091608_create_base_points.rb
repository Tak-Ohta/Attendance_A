class CreateBasePoints < ActiveRecord::Migration[5.1]
  def change
    create_table :base_points do |t|
      t.integer :base_number
      t.string :base_name
      t.string :attendance_type

      t.timestamps
    end
  end
end
