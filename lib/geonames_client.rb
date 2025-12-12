require "net/http"
require "json"

class GeonamesClient
  BASE_URL = "https://secure.geonames.org"

  def initialize(username = ENV["GEONAMES_USERNAME"])
    @username = username
    raise "GEONAMES_USERNAME is not set" if @username.nil?
  end

  # コーヒー生産国を検索
  def search_country(country_name)
    uri = URI("#{BASE_URL}/searchJSON")
    params = {
      q: country_name,
      featureClass: "A",      # 行政区分
      featureCode: "PCLI",    # 国
      maxRows: 1,
      username: @username
    }
    uri.query = URI.encode_www_form(params)

    response = Net::HTTP.get_response(uri)
    return nil unless response.is_a?(Net::HTTPSuccess)

    data = JSON.parse(response.body)
    data["geonames"]&.first
  rescue => e
    Rails.logger.error "GeoNames API Error: #{e.message}"
    nil
  end

  # 複数国を一括検索
  def search_countries(country_names)
    country_names.map do |name|
      result = search_country(name)
      sleep 0.1  # API Rate Limit対策
      result
    end.compact
  end
end
