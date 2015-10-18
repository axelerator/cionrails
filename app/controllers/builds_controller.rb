class BuildsController < ApplicationController
  before_action :load_config

  def index
    @builds = Build.all
    @build = Build.new
  end

  def create
    @build = Build.new(branch: params[:build][:branch])
    if @build.save
      redirect_to action: :index
    else
      render :index
    end
  end

  private

  def load_config
    @configuration = ::Configuration.first
    redirect_to new_configuration_path unless @configuration
  end
end

