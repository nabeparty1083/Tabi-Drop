require "json"
require "net/http"

class BrevoDelivery
  def initialize(_settings = {})
  end

  def deliver!(message)
    uri = URI("https://api.brevo.com/v3/smtp/email")
    request = Net::HTTP::Post.new(uri)
    request["api-key"] = ENV.fetch("BREVO_API_KEY")
    request["Content-Type"] = "application/json"

    body = message.html_part || message.text_part || message
    content_field = body.mime_type == "text/html" ? :htmlContent : :textContent

    request.body = JSON.generate(
      sender: { name: "Tabi Drop", email: message.from.first },
      to: message.to.map { |email| { email: email } },
      subject: message.subject,
      content_field => body.body.decoded
    )

    response = Net::HTTP.start(
      uri.host, uri.port, use_ssl: true, open_timeout: 5, read_timeout: 10
    ) { |http| http.request(request) }

    return if response.is_a?(Net::HTTPSuccess)

    raise "Brevo email delivery failed (HTTP #{response.code})"
  end
end