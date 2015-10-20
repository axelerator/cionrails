class BuildsController < ApplicationController
  before_action :load_config

  def index
    @builds = Build.all
    @branch = Branch.new
  end

  def create
    @branch = Branch.new(name: params[:branch][:name])
    if @branch.save
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

