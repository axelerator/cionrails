class Branch < ActiveRecord::Base
  validates :name, presence: true
end
