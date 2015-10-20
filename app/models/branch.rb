class Branch < ActiveRecord::Base
  validates :name, presence: true
  has_many :builds, inverse_of: :branch, dependent: :destroy

  def schedule_build
    build = self.builds.create!
    StartBuildJob.perform_later build.id
  end

  def simple_name
    name.gsub(/origin\//, '')
  end
end
