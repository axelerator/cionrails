require 'fileutils'
class ConfigurationsController < ApplicationController
  before_action :set_configuration, only: [:show, :edit, :update, :destroy]

  # GET /configurations/1
  # GET /configurations/1.json
  def show
    redirect_to action: :new unless @configuration

  end

  def new
    ssh_key_dir = Rails.root.join('config', 'deploy_key')
    path = ssh_key_dir.join('deploy_key')

    unless File.exists?(path)
      system "ssh-keygen -t rsa -b 4096 -q -N '' -f '#{path}'"
    end
    @public_key = File.read(ssh_key_dir.join('deploy_key.pub'))

    @access_token = params[:access_token]
    if @access_token.present?
      Octokit.auto_paginate = true
      client = Octokit::Client.new(access_token: @access_token)
      user = client.user
      @admin_uid = user.id
      @repos = []
      currentPage = 1
      lastPage = false
      while (!lastPage) do
        repos_response = client.get("user/repos?affiliation=owner,collaborator,organization_member&per_page=100&page=#{currentPage}")
        @repos += repos_response.map(&:full_name)
        lastPage = repos_response.length < 100
        currentPage += 1
      end
    end
  end

  # POST /configurations
  # POST /configurations.json
  def create
    raise "Already configured" if ::Configuration.count != 0
    @configuration = ::Configuration.new(admin_uid: params[:admin_uid], repo_url: params[:repo_url])
    if @configuration.save
       redirect_to action: :show, notice: 'Configuration was successfully created.'
    else
       render :new
    end
  end

  def reset
    @config = ::Configuration.first
    @config.reset! if @config
    redirect_to action: :new
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_configuration
      @configuration = ::Configuration.first
    end
end
