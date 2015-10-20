class BuildBelongsToBranch < ActiveRecord::Migration
  def change
    Build.delete_all
    remove_column :builds, :branch
    add_reference :builds, :branch, index: true, null: false
    add_foreign_key :builds, :branches
  end
end
