require 'fileutils'
require 'open3'
class Configuration < ActiveRecord::Base
  validates :admin_uid, :repo_url, presence: :true

  def name
    self.repo_url
  end

  def reset!
    FileUtils.rm([public_key, private_key])
    FileUtils.rm_rf(workspace)
    FileUtils.mkdir(workspace)
    self.destroy
    Build.delete_all
  end

  def branches
    exec_git('branch -r')
      .split("\n")
      .map{|line| line.strip.gsub(/ .*/, '') }
  end

  def workspace
    Rails.root.join('workspaces')
  end

  def repo_dir
     workspace.join('repo')
  end

  def ssh_key_dir
    Rails.root.join('config', 'deploy_key')
  end

  def public_key
    ssh_key_dir.join('deploy_key.pub').to_s
  end

  def private_key
    ssh_key_dir.join('deploy_key').to_s
  end

  def exec_git(cmd)
    cmd = "GIT_SSH_COMMAND='ssh -i #{private_key}' cd #{repo_dir} && git #{cmd}"
    `#{cmd}`
  end

  def self.current
    ::Configuration.first
  end

  def github_client
    @client ||= Octokit::Client.new(access_token: access_token)
  end

  def api_pull_requests
    github_client.get('repos/fortytools/pdf-rechnungen/pulls')
  end

  def add_deploy_key_to_github
    delploy_key_content = File.read(public_key)
    github_client.post("repos/#{repo_url}/keys", title: 'ci_onrails', key: delploy_key_content, read_only: true)
  end

  def clone_repo
    url = "git@github.com:#{repo_url}.git"
    FileUtils.mkdir_p(repo_dir)
    exec_git("clone #{url} .")
  end

end
