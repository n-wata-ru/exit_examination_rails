FactoryBot.define do
  factory :coffee_bean do
    association :user
    name { "テストコーヒー豆" }
    variety { "ゲイシャ" }
    process { "ナチュラル" }
    roast_level { "中煎り" }
    notes { "フルーティーな風味" }
  end
end
