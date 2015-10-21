class Branch < ActiveRecord::Base
  validates :name, presence: true
  has_many :builds, inverse_of: :branch, dependent: :destroy

  class PullRequest < Branch
    validates :pr_id, presence: true
    def self.create_from_pr(pr_id)
      c = ::Configuration.current
      api_pr = c.api_pull_requests.find do |pr|
        pr.id == pr_id
      end
      raise "Pull request with id #{pr_id} not found" unless api_pr
      pr = Branch::PullRequest.create!(pr_id: api_pr.head.sha, name: api_pr.head.ref)
      pr.set_github_state('pending')

    end

    def set_github_state(state_name)
      c = ::Configuration.current
      c.github_client.create_status(c.repo_url, pr_id, state_name)
    end
  end

  def schedule_build
    build = self.builds.create!
    StartBuildJob.perform_later build.id
  end

  def simple_name
    name.gsub(/origin\//, '')
  end


end
