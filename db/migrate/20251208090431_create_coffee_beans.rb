class CreateCoffeeBeans < ActiveRecord::Migration[8.1]
  def change
    create_table :coffee_beans do |t|
      t.string :name
      t.string :variety
      t.string :process
      t.string :roast_level
      t.references :origin, null: false, foreign_key: true
      t.text :notes
      t.string :image

      t.timestamps
    end
  end
end
