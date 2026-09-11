module SpotsHelper
  def safe_external_url(url)
    return if url.blank?

    uri = URI.parse(url)

    return unless uri.is_a?(URI::HTTP) && uri.host.present?

    uri.to_s
  rescue URI::InvalidURIError
    nil
  end
end
