# frozen_string_literal: true

if Rails.env.production? && ENV["SENTRY_DSN"].present?
  begin
    raise "Tabi Drop Sentry connection test"
  rescue StandardError => error
    event_id = Sentry.capture_exception(error)
    puts "Sentry test event ID: #{event_id || 'not created'}"
  ensure
    Sentry.close
  end
else
  puts "Sentry verification skipped: production and SENTRY_DSN are required"
end
