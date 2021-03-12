class AddInstructorsToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :select_superior_for_overtime, :string
    add_column :attendances, :confirm_superior_for_overtime, :string
  end
end
