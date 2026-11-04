# frozen_string_literal: true

Sentry.init do |config|
  config.dsn = ENV["SENTRY_DSN"]
  config.environment = Rails.env
  config.enabled_environments = %w[production]

  config.traces_sample_rate = 0.0
  config.breadcrumbs_logger = []
  config.rails.structured_logging.enabled = false

  config.data_collection.user_info = false
  config.data_collection.cookies.mode = :off
  config.data_collection.http_headers.request.mode = :off
  config.data_collection.http_headers.response.mode = :off
  config.data_collection.http_bodies = []
  config.data_collection.url_query_params.mode = :off
  config.data_collection.database_query_data = false
  config.data_collection.queues = false
  config.data_collection.stack_frame_variables = false
end
