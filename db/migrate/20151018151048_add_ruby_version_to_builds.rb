class AddRubyVersionToBuilds < ActiveRecord::Migration
  def change
    add_column :builds, :ruby_version, :string
  end
end
