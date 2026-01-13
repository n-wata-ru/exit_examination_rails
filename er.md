# ER設計: MyCoffeeNote

## users

| カラム名                 | 型        | 説明                    |
| ---------------------- | -------- | --------------------- |
| id                     | bigint   | 主キー                   |
| name                   | string   | ニックネームなど              |
| email                  | string   | Devise用メールアドレス        |
| encrypted_password     | string   | パスワード (Devise)        |
| reset_password_token   | string   | パスワードリセットトークン (Devise) |
| reset_password_sent_at | datetime | パスワードリセット送信日時 (Devise) |
| remember_created_at    | datetime | ログイン記憶日時 (Devise)     |
| created_at             | datetime | 作成日時                  |
| updated_at             | datetime | 更新日時                  |

---

## coffee_beans

| カラム名        | 型        | 説明                      |
| --------------- | --------- | ------------------------- |
| id              | bigint    | 主キー                     |
| name            | string    | 豆の名称                    |
| variety         | string    | 品種として、ブルボン、ゲイシャなど       |
| process         | string    | 精製方法（ナチュラル / ウォッシュド）    |
| roast_level     | string    | 焙煎度（浅煎り / 中煎り / シティ）      |
| user_id         | bigint    | `users`テーブルへの外部キー (NOT NULL) |
| origin_id       | bigint    | `origins`テーブルへの外部キー     |
| notes           | text      | フレーバーノートや備考             |
| image           | string    | 豆の画像（ActiveStorage想定）  |
| created_at      | datetime  | 作成日時                    |
| updated_at      | datetime  | 更新日時                    |

---

## tasting_notes

| カラム名             | 型        | 説明                         |
| -------------------- | --------- | ---------------------------- |
| id                   | bigint    | 主キー                        |
| user_id              | bigint    | `users`への外部キー              |
| coffee_bean_id       | bigint    | `coffee_beans`への外部キー       |
| shop_id              | bigint    | `shops`への外部キー（任意）       |
| brew_method          | string    | 抽出方法（ハンドドリップ等）        |
| preference_score     | integer   | 好み度（1〜5）⭐️ UI表示          |
| acidity_score        | integer   | 酸味の強さ（1〜5）                |
| bitterness_score     | integer   | 苦味の強さ（1〜5）                |
| sweetness_score      | integer   | 甘さ（1〜5）                    |
| taste_notes          | text      | 自由記載の風味感想                  |
| created_at           | datetime  | 作成日時（飲んだ日）               |
| updated_at           | datetime  | 更新日時                        |

---

## shops

| カラム名     | 型        | 説明                  |
| ------------ | --------- | --------------------- |
| id           | bigint    | 主キー                 |
| name         | string    | 店舗名                 |
| address      | string    | 住所（入力形式）           |
| url          | string    | 店舗WebサイトURL         |
| notes        | text      | 接客や印象の自由メモ         |
| created_at   | datetime  | 作成日時                |
| updated_at   | datetime  | 更新日時                |

---

## origins

| カラム名       | 型              | 説明                              |
| ------------ | --------------- | --------------------------------- |
| id           | bigint          | 主キー                             |
| country      | string          | 国名（例: エチオピア）               |
| country_code | string(2)       | ISO 3166-1 alpha-2 国コード (例: ET) |
| region       | string          | 地域（例: グジ）                    |
| farm_name    | string          | 農園名（例: トレスポソス）             |
| geonames_id  | integer         | GeoNames APIのID                   |
| latitude     | decimal(10, 6)  | 緯度                               |
| longitude    | decimal(10, 6)  | 経度                               |
| notes        | text            | 備考（標高、生産者、ロット情報など）     |
| created_at   | datetime        | 作成日時                            |
| updated_at   | datetime        | 更新日時                            |

---

## chat_threads

| カラム名       | 型              | 説明                              |
| ------------ | --------------- | --------------------------------- |
| id           | bigint          | 主キー                             |
| user_id      | bigint          | `users`への外部キー (NOT NULL)      |
| title        | string          | スレッド (NOT NULL) 名                          |
| created_at   | datetime        | 作成日時                            |
| updated_at   | datetime        | 更新日時                            |

---

## chat_messages

| カラム名         | 型        | 説明                                      |
| --------------- | --------- | ---------------------------------------- |
| id              | bigint    | 主キー                                    |
| chat_thread_id  | bigint    | `chat_threads`への外部キー (NOT NULL)      |
| user_id         | bigint    | `users`への外部キー             |
| role            | string    | メッセージの送信者 ("user" or "assistant" NOT NULL) |
| content         | text      | メッセージ内 (NOT NULL)容                              |
| created_at      | datetime  | 作成日時                                   |
| updated_at      | datetime  | 更新日時                                   |
