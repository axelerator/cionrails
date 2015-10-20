module ApplicationHelper

  def state_icon(build)
    state_icons = {
      "created" => fa_icon('question-circle'),
      "checkout" => fa_icon('cloud-download'),
      "waiting_for_build" => fa_icon('clock-o'),
      "building" => fa_icon('gears'),
      "failed" => fa_icon('thumbs-down'),
      "aborted" => fa_icon('exclamation-circle'),
      "succeeded" => fa_icon('thumbs-up')
    }

    state_icons[build.state] || fa_icon('question-circle')
  end
end
