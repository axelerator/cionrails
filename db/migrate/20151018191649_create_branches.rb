class CreateBranches < ActiveRecord::Migration
  def change
    create_table :branches do |t|
      t.string :name, null: false

      t.timestamps null: false
    end
  end
end
