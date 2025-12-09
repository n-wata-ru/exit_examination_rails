class CreateShops < ActiveRecord::Migration[8.1]
  def change
    create_table :shops do |t|
      t.string :name
      t.string :address
      t.string :url
      t.text :notes

      t.timestamps
    end
  end
end
