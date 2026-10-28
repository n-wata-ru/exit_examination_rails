module OpenAi
  class VisionService
    RESPONSE_KEYS = %w[name origin_country variety process roast_level notes].freeze

    SYSTEM_PROMPT = <<~PROMPT.freeze
      あなたはコーヒーパッケージの画像からコーヒー豆の情報を抽出する専門家です。
      画像に写っているテキストやラベルの情報のみをもとに、以下のJSON形式で回答してください。
      画像から読み取れない項目は空文字列にしてください。推測で埋めないでください。

      {
        "name": "商品名・銘柄名（コーヒー名）",
        "origin_country": "生産国名（英語表記。例: Ethiopia, Colombia, Brazil, Kenya, Guatemala, Costa Rica, Honduras, Peru）",
        "variety": "品種（例: ゲイシャ、ティピカ、ブルボン、カトゥアイ、ロブスタ など）",
        "process": "処理方法。次の選択肢から完全に一致するものを1つだけ選んでください: ナチュラル, ウォッシュド, ハニー, アナエロビック, カーボニックマセレーション, スマトラ式, その他",
        "roast_level": "焙煎度。次の選択肢から完全に一致するものを1つだけ選んでください: 浅煎り, 中煎り, 中深煎り, 深煎り",
        "notes": "風味・香りなどパッケージに記載された特徴の簡潔なメモ"
      }
    PROMPT

    def initialize
      @client = OpenAI::Client.new(
        access_token: ENV.fetch("OPENAI_API_KEY")
      )
    end

    def extract_coffee_info(image_data_url:)
      response = @client.chat(
        parameters: {
          model: "gpt-4o",
          messages: [
            { role: "system", content: SYSTEM_PROMPT },
            {
              role: "user",
              content: [
                { type: "text", text: "この画像からコーヒー豆の情報を抽出してください。" },
                { type: "image_url", image_url: { url: image_data_url } }
              ]
            }
          ],
          temperature: 0,
          response_format: { type: "json_object" }
        }
      )

      content = response.dig("choices", 0, "message", "content")
      parsed = JSON.parse(content.to_s)

      RESPONSE_KEYS.each_with_object({}) do |key, result|
        result[key] = parsed[key].to_s.strip
      end
    rescue => e
      Rails.logger.error("OpenAI Vision API Error: #{e.message}")
      raise
    end
  end
end
