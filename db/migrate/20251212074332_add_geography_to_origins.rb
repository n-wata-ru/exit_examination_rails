class AddGeographyToOrigins < ActiveRecord::Migration[8.1]
  def change
    add_column :origins, :latitude, :decimal, precision: 10, scale: 6
    add_column :origins, :longitude, :decimal, precision: 10, scale: 6
    add_column :origins, :geonames_id, :integer
    add_column :origins, :country_code, :string, limit: 2

    add_index :origins, :geonames_id, unique: true
    add_index :origins, :country_code
  end
end
