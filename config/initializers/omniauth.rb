Rails.application.config.middleware.use OmniAuth::Builder do
  provider :github, '6ad69cd0a2cf126540ad', 'c5c0dcfcfc65c97b98d9fad8f65ec863511b89d8'
end
