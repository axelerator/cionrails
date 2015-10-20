class StartBuildJob < ActiveJob::Base
  queue_as :default

  def perform(build_id)
    build = Build.find(build_id)
    build.checkout
  end
end
