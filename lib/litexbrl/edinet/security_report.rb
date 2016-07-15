module LiteXBRL
  module Edinet
    class SecurityReport < FinancialInformation
      include SecurityReportAttribute

      def self.read(doc)
        xbrl = read_data doc

        {security_report: xbrl.attributes}
      end

      private

      def self.read_data(doc)
        xbrl, context, id = find_base_data(doc)
        find_data(doc, xbrl, context, id)

      end

      def self.find_base_data(doc)
        consolidation, season = find_consolidation_and_season(doc)
        # binding.pry
        context = context_hash(consolidation, season)
        id = id_hash(consolidation, season)

        xbrl = new

        # 証券コード
        xbrl.code = find_securities_code(doc, consolidation)
        # 決算年
        xbrl.year = find_year(doc, consolidation)
        # 決算月
        xbrl.month = find_month(doc, consolidation)
        # 四半期
        xbrl.quarter = find_quarter(doc, consolidation, context)
        # 連結・非連結
        xbrl.consolidation = to_consolidation(consolidation)

        return xbrl, context, id
      end

      def self.find_consolidation_and_season(doc)
        consolidation = find_consolidation(doc)
        season = find_season(doc, consolidation)

        # 連結で取れない場合、非連結にする
        unless season
          consolidation = "NonConsolidatedMember"
          season = find_season(doc, consolidation)
        end

        return consolidation, season
      end

      #
      # 通期・四半期を取得します
      #
      def self.find_season(doc, consolidation)

        year = doc.at_xpath("//xbrli:xbrl/xbrli:context[@id='CurrentYearInstant_#{consolidation}' or @id='CurrentYearInstant']/xbrli:entity/xbrli:identifier")
        quarter = doc.at_xpath("//xbrli:xbrl/xbrli:context[@id='CurrentQuarterInstant_#{consolidation}' or @id='CurrentQuarterInstant']/xbrli:entity/xbrli:identifier")
        q1 = doc.at_xpath("//xbrli:xbrl/xbrli:context[@id='Prior1QuarterInstant_#{consolidation}' or @id='Prior1QuarterInstant']/xbrli:entity/xbrli:identifier")
        q2 = doc.at_xpath("//xbrli:xbrl/xbrli:context[@id='Prior2QuarterInstant_#{consolidation}' or @id='Prior2QuarterInstant']/xbrli:entity/xbrli:identifier")
        q3 = doc.at_xpath("//xbrli:xbrl/xbrli:context[@id='Prior3QuarterInstant_#{consolidation}' or @id='Prior3QuarterInstant']/xbrli:entity/xbrli:identifier")

        if year
          "Year"
        elsif quarter
          "Quarter"
        elsif q1
          "AccumulatedQ1"
        elsif q2
          "AccumulatedQ2"
        elsif q3
          "AccumulatedQ3"
        end
      end

      def self.find_data(doc, xbrl, context, id)
        # 売上高
        xbrl.net_sales = find_value_jp_cor(doc, NET_SALES, context[:context_duration], context[:context_consolidation])
        # 営業利益
        xbrl.operating_income = find_value_jp_cor(doc, OPERATING_INCOME, context[:context_duration], context[:context_consolidation])
        # 経常利益
        xbrl.ordinary_income = find_value_jp_cor(doc, ORDINARY_INCOME, context[:context_duration], context[:context_consolidation])
        # 純利益
        xbrl.net_income = find_value_jp_cor(doc, NET_INCOME, context[:context_duration], context[:context_consolidation])
        # 1株当たり純利益
        xbrl.net_income_per_share = find_value_to_f(doc, NET_INCOME_PER_SHARE, context[:context_duration], context[:context_consolidation])

        # 売上高前年比
        xbrl.change_in_net_sales = find_value_to_f(doc, CHANGE_IN_NET_SALES, context[:context_duration], context[:context_consolidation])
        # 営業利益前年比
        xbrl.change_in_operating_income = find_value_to_f(doc, CHANGE_IN_OPERATING_INCOME, context[:context_duration], context[:context_consolidation])
        # 経常利益前年比
        xbrl.change_in_ordinary_income = find_value_to_f(doc, CHANGE_IN_ORDINARY_INCOME, context[:context_duration], context[:context_consolidation])
        # 純利益前年比
        xbrl.change_in_net_income = find_value_to_f(doc, CHANGE_IN_NET_INCOME, context[:context_duration], context[:context_consolidation])

        # 前期売上高
        xbrl.prior_net_sales = find_value_to_mill(doc, NET_SALES, context[:context_prior_duration], context[:context_consolidation])
        # 前期営業利益
        xbrl.prior_operating_income = find_value_to_mill(doc, OPERATING_INCOME, context[:context_prior_duration], context[:context_consolidation])
        # 前期経常利益
        xbrl.prior_ordinary_income = find_value_to_mill(doc, ORDINARY_INCOME, context[:context_prior_duration], context[:context_consolidation])
        # 前期純利益
        xbrl.prior_net_income = find_value_to_mill(doc, NET_INCOME, context[:context_prior_duration], context[:context_consolidation])
        # 前期1株当たり純利益
        xbrl.prior_net_income_per_share = find_value_to_f(doc, NET_INCOME_PER_SHARE, context[:context_prior_duration], context[:context_consolidation])

        # 前期売上高前年比
        xbrl.change_in_prior_net_sales = find_value_to_f(doc, CHANGE_IN_NET_SALES, context[:context_prior_duration], context[:context_consolidation])
        # 前期営業利益前年比
        xbrl.change_in_prior_operating_income = find_value_to_f(doc, CHANGE_IN_OPERATING_INCOME, context[:context_prior_duration], context[:context_consolidation])
        # 前期経常利益前年比
        xbrl.change_in_prior_ordinary_income = find_value_to_f(doc, CHANGE_IN_ORDINARY_INCOME, context[:context_prior_duration], context[:context_consolidation])
        # 前期純利益前年比
        xbrl.change_in_prior_net_income = find_value_to_f(doc, CHANGE_IN_NET_INCOME, context[:context_prior_duration], context[:context_consolidation])

        # 株主資本
        xbrl.owners_equity = find_value_to_mill(doc, OWNERS_EQUITY, context[:context_instant], context[:context_consolidation])
        # 期末発行済株式数
        xbrl.number_of_shares = find_value_to_i(doc, NUMBER_OF_SHARES, context[:context_instant], context[:context_consolidation])
        # 期末自己株式数
        xbrl.number_of_treasury_stock = find_value_to_i(doc, NUMBER_OF_TREASURY_STOCK, context[:context_instant], context[:context_consolidation])
        # 1株当たり純資産
        xbrl.net_assets_per_share = find_value_to_f(doc, NET_ASSETS_PER_SHARE, context[:context_instant], context[:context_consolidation])

        # 1株当たり純資産がない場合、以下の計算式で計算する
        # 1株当たり純資産 = 株主資本 / (期末発行済株式数 - 期末自己株式数)
        if xbrl.net_assets_per_share.nil? && xbrl.owners_equity && xbrl.number_of_shares
          xbrl.net_assets_per_share = (
            xbrl.owners_equity.to_f * 1000 * 1000 / (xbrl.number_of_shares - xbrl.number_of_treasury_stock.to_i)
          ).round 2
        end

        # 通期予想売上高
        xbrl.forecast_net_sales = find_value_to_mill(doc, FORECAST_NET_SALES, context[:context_forecast].call(xbrl.quarter), context[:context_consolidation])
        # 通期予想営業利益
        xbrl.forecast_operating_income = find_value_to_mill(doc, FORECAST_OPERATING_INCOME, context[:context_forecast].call(xbrl.quarter), context[:context_consolidation])
        # 通期予想経常利益
        xbrl.forecast_ordinary_income = find_value_to_mill(doc, FORECAST_ORDINARY_INCOME, context[:context_forecast].call(xbrl.quarter), context[:context_consolidation])
        # 通期予想純利益
        xbrl.forecast_net_income = find_value_to_mill(doc, FORECAST_NET_INCOME, context[:context_forecast].call(xbrl.quarter), context[:context_consolidation])
        # 通期予想1株当たり純利益
        xbrl.forecast_net_income_per_share = find_value_to_f(doc, FORECAST_NET_INCOME_PER_SHARE, context[:context_forecast].call(xbrl.quarter), context[:context_consolidation])




        # 通期予想売上高前年比
        xbrl.change_in_forecast_net_sales = find_value_to_f(doc, CHANGE_FORECAST_NET_SALES, context[:context_forecast].call(xbrl.quarter), context[:context_consolidation])
        # 通期予想営業利益前年比
        xbrl.change_in_forecast_operating_income = find_value_to_f(doc, CHANGE_FORECAST_OPERATING_INCOME, context[:context_forecast].call(xbrl.quarter), context[:context_consolidation])
        # 通期予想経常利益前年比
        xbrl.change_in_forecast_ordinary_income = find_value_to_f(doc, CHANGE_FORECAST_ORDINARY_INCOME, context[:context_forecast].call(xbrl.quarter), context[:context_consolidation])
        # 通期予想純利益前年比
        xbrl.change_in_forecast_net_income = find_value_to_f(doc, CHANGE_FORECAST_NET_INCOME, context[:context_forecast].call(xbrl.quarter), context[:context_consolidation])

        # 報告書のタイプ
        xbrl.document_title_cover_page = find_value_jp_cor(doc, DOCUMENT_TITLE_COVER_PAGE, context[:filing_date_instant], context[:context_consolidation])

        # 決算期
        xbrl.fiscal_year_cover_page = find_value_jp_cor(doc, FISCAL_YEAR_COVER_PAGE, context[:filing_date_instant], context[:context_consolidation])

        # 決算月
        xbrl.current_fiscal_year_end_date = find_value_jp_cor(doc, CURRENT_FISCAL_YEAR_END_DATE, context[:filing_date_instant], context[:context_consolidation])

        # 企業名
        xbrl.company_name = find_value_jp_cor(doc, COMPANY_NAME, context[:filing_date_instant], context[:context_consolidation])

        # 提出日
        xbrl.filing_date = find_value_jp_cor(doc, FILING_DATE, context[:filing_date_instant], context[:context_consolidation])

        # 従業員数
        xbrl.number_of_employees = find_value_jp_cor(doc, NUMBER_OF_EMPLOYEES, context[:context_instant], context[:context_consolidation])

        # セグメント情報
        elm_array = find_value_reportable_segments_member(doc, id[:reportable_segments_member])

        xbrl.segments = Array.new()
        elm_array.each do |elm|
          segment = segment_hash
          segment[:segment_context_ref_name] = to_segment_context_ref_name(elm.content, context[:context_duration])
          segment[:segment_english_name] = to_segment_english_name(elm)
          segment[:segment_sales] = find_value_jp_cor(doc, NET_SALES, segment[:segment_context_ref_name], context[:context_consolidation])
          segment[:segment_operating_profit] = find_value_jp_cor(doc, OPERATING_INCOME, segment[:segment_context_ref_name], context[:context_consolidation])
          xbrl.segments.push segment
        end

        xbrl
      end

      def self.find_value_to_mill(doc, item, context, context_consolidation)
        to_mill find_value_jp_cor(doc, item, context, context_consolidation)
      end

      def self.find_value_to_i(doc, item, context, context_consolidation)
        to_i find_value_jp_cor(doc, item, context, context_consolidation)
      end

      def self.find_value_to_f(doc, item, context, context_consolidation)
        to_f find_value_jp_cor(doc, item, context, context_consolidation)
      end

    end
  end
end
