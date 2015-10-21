class AddPrIdToBranch < ActiveRecord::Migration
  def change
    add_column :branches, :pr_id, :string
    add_column :branches, :type, :string
  end
end
