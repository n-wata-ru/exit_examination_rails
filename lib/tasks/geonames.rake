namespace :geonames do
  desc "Import coffee producing countries from GeoNames API"
  task import_countries: :environment do
    require_relative "../geonames_client"

    # コーヒー主要生産国リスト
    coffee_countries = [
      "Ethiopia",
      "Colombia",
      "Brazil",
      "Kenya",
      "Guatemala",
      "Costa Rica",
      "Honduras",
      "Peru",
      "Tanzania",
      "Rwanda",
      "Burundi",
      "Panama",
      "Indonesia",
      "Vietnam",
      "India",
      "Yemen",
      "Nicaragua",
      "El Salvador",
      "Mexico",
      "Jamaica",
      "Papua New Guinea",
      "Uganda",
      "Malawi"
    ]

    client = GeonamesClient.new

    puts "Importing #{coffee_countries.count} countries..."

    coffee_countries.each do |country_name|
      print "Fetching #{country_name}... "

      result = client.search_country(country_name)

      if result
        origin = Origin.find_or_initialize_by(geonames_id: result["geonameId"])
        origin.assign_attributes(
          country: result["name"],
          country_code: result["countryCode"],
          latitude: result["lat"],
          longitude: result["lng"]
        )

        if origin.save
          puts "✓ Saved"
        else
          puts "✗ Error: #{origin.errors.full_messages.join(', ')}"
        end
      else
        puts "✗ Not found"
      end

      sleep 0.1  # API Rate Limit
    end

    puts "\nImport completed!"
    puts "Total origins: #{Origin.count}"
  end
end
