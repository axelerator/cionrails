class BranchesController < ApplicationController

  def build_now
    @branch = Branch.find(params[:id])
    @branch.schedule_build
    redirect_to builds_path
  end
end
