class VisitorsController < ApplicationController
  skip_before_action :assert_current_user
end
