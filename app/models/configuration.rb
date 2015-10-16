class Configuration < ActiveRecord::Base
  validates :admin_uid, :repo_url, presence: :true
  before_save :build_keys, unless: :persisted?



  private

  def build_keys
    path = Rails.root.join('config', 'deploy_key', 'deploy_key')
    system "ssh-keygen -t rsa -b 4096 -q -N '' -f '#{path}'"
  end
end
