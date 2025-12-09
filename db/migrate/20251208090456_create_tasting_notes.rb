class CreateTastingNotes < ActiveRecord::Migration[8.1]
  def change
    create_table :tasting_notes do |t|
      t.references :user, null: false, foreign_key: true
      t.references :coffee_bean, null: false, foreign_key: true
      t.references :shop, null: true, foreign_key: true
      t.string :brew_method
      t.integer :preference_score
      t.integer :acidity_score
      t.integer :bitterness_score
      t.integer :sweetness_score
      t.text :taste_notes

      t.timestamps
    end
  end
end
