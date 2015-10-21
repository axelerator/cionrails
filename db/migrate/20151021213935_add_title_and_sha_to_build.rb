class AddTitleAndShaToBuild < ActiveRecord::Migration
  def change
    add_column :builds, :sha, :string
    add_column :builds, :title, :string
  end
end
