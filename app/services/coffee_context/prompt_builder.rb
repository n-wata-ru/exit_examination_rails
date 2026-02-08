module CoffeeContext
  class PromptBuilder
    MAX_BEANS = 50

    def initialize(user)
      @user = user
    end

    def build
      coffee_data = build_coffee_data
      build_system_prompt(coffee_data)
    end

    private

    def build_system_prompt(coffee_data)
      base_prompt = <<~PROMPT.strip
        あなたはコーヒーの専門家アシスタントです。
        ユーザーのコーヒー豆のコレクションとテイスティングノートのデータに基づいて、
        コーヒーに関する質問に答えたり、おすすめを提案したり、味の傾向を分析したりしてください。

        以下の点を心がけてください：
        - ユーザーのデータに基づいた具体的なアドバイスをすること
        - コーヒーの専門知識を活かして分かりやすく説明すること
        - 味の好みの傾向を把握し、新しいコーヒーの提案に活かすこと
        - 丁寧な日本語で回答すること
      PROMPT

      if coffee_data.present?
        "#{base_prompt}\n\n#{coffee_data}"
      else
        "#{base_prompt}\n\n現在、ユーザーはまだコーヒー豆のデータを登録していません。コーヒーに関する一般的な知識でサポートしてください。"
      end
    end

    def build_coffee_data
      beans = @user.coffee_beans
                    .includes(:origin, tasting_notes: :shop)
                    .order(created_at: :desc)
                    .limit(MAX_BEANS)

      return nil if beans.empty?

      sections = [ "【ユーザーのコーヒー豆データ】" ]

      beans.each_with_index do |bean, index|
        sections << format_bean(bean, index + 1)
      end

      sections.join("\n\n")
    end

    def format_bean(bean, number)
      lines = []
      lines << "--- コーヒー豆 #{number}: #{bean.name} ---"
      lines << "品種: #{bean.variety}" if bean.variety.present?
      lines << "精製方法: #{bean.process}" if bean.process.present?
      lines << "焙煎度: #{bean.roast_level}" if bean.roast_level.present?
      lines << "メモ: #{bean.notes}" if bean.notes.present?

      if bean.origin
        origin_parts = []
        origin_parts << "国: #{bean.origin.country}" if bean.origin.country.present?
        origin_parts << "地域: #{bean.origin.region}" if bean.origin.region.present?
        origin_parts << "農園: #{bean.origin.farm_name}" if bean.origin.farm_name.present?
        lines << "産地: #{origin_parts.join(', ')}" if origin_parts.any?
      end

      if bean.tasting_notes.any?
        lines << "テイスティングノート:"
        bean.tasting_notes.each_with_index do |note, note_index|
          lines << format_tasting_note(note, note_index + 1)
        end
      end

      lines.join("\n")
    end

    def format_tasting_note(note, number)
      parts = []
      parts << "  [記録#{number}]"
      parts << "  抽出方法: #{note.brew_method}" if note.brew_method.present?
      parts << "  好み: #{note.preference_score}/5" if note.preference_score
      parts << "  酸味: #{note.acidity_score}/5" if note.acidity_score
      parts << "  苦味: #{note.bitterness_score}/5" if note.bitterness_score
      parts << "  甘味: #{note.sweetness_score}/5" if note.sweetness_score
      parts << "  テイストメモ: #{note.taste_notes}" if note.taste_notes.present?

      if note.shop
        shop_info = note.shop.name
        shop_info += " (#{note.shop.address})" if note.shop.address.present?
        parts << "  購入店: #{shop_info}"
      end

      parts.join("\n")
    end
  end
end
