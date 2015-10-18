require 'fileutils'
require 'open3'
class Configuration < ActiveRecord::Base
  validates :admin_uid, :repo_url, presence: :true
  before_save :clone_repo, unless: :persisted?

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

  def clone_repo
    url = "git@github.com:#{repo_url}.git"
    FileUtils.mkdir_p(repo_dir)
    exec_git("clone #{url} .")
  end

end
