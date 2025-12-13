class AddUserIdToCoffeeBeans < ActiveRecord::Migration[8.1]
  def change
    # まずnull許可でカラムを追加
    add_reference :coffee_beans, :user, null: true, foreign_key: true

    # 既存データに user_id: 12 を設定
    reversible do |dir|
      dir.up do
        execute "UPDATE coffee_beans SET user_id = 12 WHERE user_id IS NULL"
      end
    end

    # NOT NULL制約を追加
    change_column_null :coffee_beans, :user_id, false
  end
end
