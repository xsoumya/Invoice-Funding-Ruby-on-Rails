require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.cache_classes = true
  config.eager_load = true
  config.consider_all_requests_local = false
  config.public_file_server.enabled = true
  config.force_ssl = ENV.fetch("FORCE_SSL", "false") == "true"
  config.log_level = ENV.fetch("LOG_LEVEL", "info")
  config.logger = ActiveSupport::Logger.new($stdout)
  config.active_support.deprecation = :notify
end
