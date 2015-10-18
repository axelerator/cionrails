class CreateBuilds < ActiveRecord::Migration
  def change
    create_table :builds do |t|
      t.integer :state, null: false, default: 0
      t.text :branch, null: false
      t.text :output, null: false, default: ''

      t.timestamps null: false
    end
  end
end
