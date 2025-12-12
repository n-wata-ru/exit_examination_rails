class ChangeCoffeeBeansOriginToNullable < ActiveRecord::Migration[8.1]
  def change
    change_column_null :coffee_beans, :origin_id, true
  end
end
