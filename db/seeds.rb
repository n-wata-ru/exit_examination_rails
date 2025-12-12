# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# GeoNamesからOriginデータをインポート
if Origin.count.zero?
  puts "Importing origins from GeoNames..."

  begin
    # GeoNames APIを使用してデータをインポート
    Rake::Task['geonames:import_countries'].invoke
  rescue => e
    puts "Error importing from GeoNames: #{e.message}"
    puts "Falling back to manual data..."

    # フォールバック: 手動データ（GeoNames APIが使えない場合）
    coffee_countries = [
      { country: 'Ethiopia', country_code: 'ET', latitude: 9.145, longitude: 40.4897, geonames_id: 337996 },
      { country: 'Colombia', country_code: 'CO', latitude: 4.5709, longitude: -74.2973, geonames_id: 3686110 },
      { country: 'Brazil', country_code: 'BR', latitude: -14.235, longitude: -51.9253, geonames_id: 3469034 },
      { country: 'Kenya', country_code: 'KE', latitude: -0.0236, longitude: 37.9062, geonames_id: 192950 },
      { country: 'Guatemala', country_code: 'GT', latitude: 15.7835, longitude: -90.2308, geonames_id: 3598132 },
      { country: 'Costa Rica', country_code: 'CR', latitude: 9.7489, longitude: -83.7534, geonames_id: 3624060 },
      { country: 'Honduras', country_code: 'HN', latitude: 15.2, longitude: -86.2419, geonames_id: 3608932 },
      { country: 'Peru', country_code: 'PE', latitude: -9.19, longitude: -75.0152, geonames_id: 3932488 }
    ]

    coffee_countries.each do |data|
      Origin.find_or_create_by!(geonames_id: data[:geonames_id]) do |origin|
        origin.country = data[:country]
        origin.country_code = data[:country_code]
        origin.latitude = data[:latitude]
        origin.longitude = data[:longitude]
      end
    end
  end
end

puts "Origins: #{Origin.count}"
