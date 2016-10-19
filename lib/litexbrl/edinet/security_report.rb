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

        # 報告書のタイプ
        xbrl.document_title_cover_page = find_value_jp_cor(doc, DOCUMENT_TITLE_COVER_PAGE, context[:filing_date_instant], context[:context_consolidation])

        # 決算期
        xbrl.fiscal_year_cover_page = find_value_jp_cor(doc, FISCAL_YEAR_COVER_PAGE, context[:filing_date_instant], context[:context_consolidation])

        # 企業名
        xbrl.company_name = find_value_jp_cor(doc, COMPANY_NAME, context[:filing_date_instant], context[:context_consolidation])

        # 提出日
        xbrl.filing_date = find_value_jp_cor(doc, FILING_DATE, context[:filing_date_instant], context[:context_consolidation])

        # 当事業年度開始日
        xbrl.current_fiscal_year_start_date = find_value_jp_cor(doc, CURRENT_FISCAL_YEAR_START_DATE, context[:filing_date_instant], context[:context_consolidation])

        # 当事業年度終了日
        xbrl.current_fiscal_year_end_date = find_value_jp_cor(doc, CURRENT_FISCAL_YEAR_END_DATE, context[:filing_date_instant], context[:context_consolidation])

        # 当会計期間終了日
        xbrl.current_period_end_date = find_value_jp_cor(doc, CURRENT_PERIOD_END_DATE, context[:filing_date_instant], context[:context_consolidation])

        # 当会計期間開始日
        xbrl.current_period_start_date = find_value_jp_cor(doc, CURRENT_PERIOD_START_DATE, context[:filing_date_instant], context[:context_consolidation])

        # 当会計期間の種類
        xbrl.type_of_current_period = find_value_jp_cor(doc, TYPE_OF_CURRENT_PERIOD, context[:filing_date_instant], context[:context_consolidation])

        # 従業員数
        xbrl.number_of_employees = find_value_jp_cor(doc, NUMBER_OF_EMPLOYEES, context[:context_instant], context[:context_consolidation])

        # セグメント情報
        xbrl.segments = Array.new()
        single_segment = doc.xpath "/xbrli:xbrl/jpcrp_cor:DescriptionOfFactThatCompanysBusinessComprisesSingleSegment"
        if single_segment.empty?
          elm_array = find_value_reportable_segments_member(doc, id[:reportable_segments_member])
          elm_array.each do |elm|
            segment = segment_hash
            segment[:segment_context_ref_name] = elm.content.delete(":")
            segment[:segment_english_name] = to_segment_english_name(elm)
            segment[:segment_sales] = find_value_jp_cor_segment(doc, NET_SALES, segment[:segment_context_ref_name], context[:context_duration], context[:context_consolidation])
            segment[:segment_operating_profit] = find_value_jp_cor_segment(doc, OPERATING_INCOME, segment[:segment_context_ref_name], context[:context_duration], context[:context_consolidation])
            xbrl.segments.push segment
          end
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
