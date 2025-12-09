class CreateOrigins < ActiveRecord::Migration[8.1]
  def change
    create_table :origins do |t|
      t.string :country
      t.string :region
      t.string :farm_name
      t.text :notes

      t.timestamps
    end
  end
end
