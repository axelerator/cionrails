require 'fileutils'
require 'open3'
require 'open4'
class Build < ActiveRecord::Base
  enum state: [:created, :checkout, :waiting_for_build, :building, :succeeded, :aborted, :failed]
  belongs_to :branch, inverse_of: :builds

  validates :branch, presence: true

  before_destroy :clear_working_dir

  def checkout
    raise "expected to be in state created" unless created?
    self.checkout!
    config.exec_git('fetch')
    config.exec_git("checkout #{branch.name}")
    sha, *msg = config.exec_git('log --oneline -1').split(/\s+/)

    system "rsync -qav --exclude=\".*\" #{config.repo_dir.join('*')} #{working_dir}"
    update_attribute(:ruby_version, ruby_version_from_gemfile)
    self.update_attributes(sha: sha, title: msg.join(' '))
    self.waiting_for_build!
    ExecBuildJob.perform_later(self.id)
  end

  def build
    raise "exepcted to be in state waiting_for_build" unless waiting_for_build?
    self.building!
    execute_in_rbenv "bundle"
    status = execute_in_rbenv "bundle exec rake test"
    if status == 0
      self.succeeded!
      branch.set_github_state('success') if branch.is_a? Branch::PullRequest
    else
      self.failed!
      branch.set_github_state('failure') if branch.is_a? Branch::PullRequest
    end
  end

  def clear_working_dir
    FileUtils.rm_rf(working_dir)
  end

  def working_dir
    raise "No work for unpersisted builds!!" unless id.present?
    @working_dir = config.workspace.join('builds', id.to_s)
    FileUtils.mkdir_p(@working_dir)
    @working_dir
  end

  def ruby_version_from_gemfile
    raise "cannot eval ruby version unless code is checked out" if created?
    stdin, stdout, stderr = Open3.popen3("cd #{working_dir} && grep '^ruby' Gemfile")
    @ruby_version ||= stdout.gets.gsub(/(ruby\s*|\n|'|")/, '')
  end

  def ruby_available?
    # space after version to avoid matching wrong version with suffix
    stdin, stdout, stderr = Open3.popen3("rbenv versions | grep '#{ruby_version} '")
    ruby_version_available = stdout.gets.present?
    unless ruby_version_available
      self.failed!
      return
    end
  end

  def bundler_available?
    stdin, stdout, stderr = Open3.popen3("RBENV_VERSION=#{ruby_version} gem list | grep '^bundler '")
    stdout.gets.present?
  end

  def install_bundler
    pid, stdin, stdout, stderr = Open4::popen4 "rbenv shell #{ruby_version}; gem install bundler"
    stdout.fcntl(Fcntl::F_SETFL, Fcntl::O_NONBLOCK)
    streamer(self, stdout)
  end

  def configure
    if ruby_available? && !bundler_available?
      install_bundler
    end
    bundle
  end

  def execute_in_rbenv(cmd)
    status = nil
    Bundler.with_clean_env do
      wrapped = "cd #{working_dir} && BUNDLE_GEMFILE=#{working_dir}/Gemfile RBENV_VERSION=#{ruby_version} rbenv exec #{cmd}"
      status = Open4::popen4 wrapped do |pid, stdin, stdout, stderr|
        stdout.fcntl(Fcntl::F_SETFL, Fcntl::O_NONBLOCK)
        streamer(self, stdout)
      end
    end
    status
  end

  def streamer(build, stdout)
    begin
      loop do
        data = stdout.read_nonblock(80)
        build.output += data
        build.save!
      end
    rescue Errno::EAGAIN
      retry
    rescue EOFError
    end
  end

  private

  def config
    @config = ::Configuration.first
    raise "No builds until configured!!!" unless @config
    @config
  end

end
