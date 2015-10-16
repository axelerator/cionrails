class CreateConfigurations < ActiveRecord::Migration
  def change
    create_table :configurations do |t|
      t.string :repo_url, null: false
      t.string :admin_uid, null: false
      t.timestamps null: false
    end
  end
end
