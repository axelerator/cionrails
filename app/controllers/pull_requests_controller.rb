class PullRequestsController < ApplicationController
  def create
    pr_id = params[:pull_request][:id]
    Branch::PullRequest.create_from_pr(pr_id.to_i)
    redirect_to builds_path
  end
end
