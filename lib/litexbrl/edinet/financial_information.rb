module LiteXBRL
  module Edinet
    class FinancialInformation
      extend Utils
      include AccountItem

      class << self

        private

        def read(doc)
          xbrl, accounting_base, context = find_base_data(doc)

          find_data(doc, xbrl, accounting_base, context)
        end

        #
        # 連結・非連結を取得します
        #
        def find_consolidation(doc)
          cons = doc.at_xpath("//xbrli:xbrl/xbrli:context[@id='CurrentYearDuration' or @id='CurrentYTDDuration']/xbrli:entity/xbrli:identifier")
          non_cons = doc.at_xpath("//xbrli:xbrl/xbrli:context[@id='CurrentYearDuration_NonConsolidatedMember' or @id='CurrentYTDDuration_NonConsolidatedMember']/xbrli:entity/xbrli:identifier")

          puts "cons : #{cons}"
          puts "non_cons : #{non_cons}"

          if cons
            "Consolidated"
          elsif non_cons
            "NonConsolidatedMember"
          else
            raise StandardError.new("連結・非連結ともに該当しません。")
          end
        end

        #
        # contextを設定します
        #
        def context_hash(consolidation, season)
          puts "season2 : #{season}"
          raise StandardError.new("通期・四半期が設定されていません。") unless season

          year_duration = season == "Quarter" ? "YTDDuration_#{consolidation}" : "#{season}Duration_#{consolidation}"
          {
            context_duration: "Current#{year_duration}",
            context_prior_duration: "Prior#{year_duration}",
            context_instant: "Current#{season}Instant",
            context_instant_consolidation: "Current#{season}Instant_#{consolidation}",
            context_forecast: ->(quarter) { quarter == 4 ? "Next#{year_duration}" : "Current#{year_duration}"},
            filing_date_instant: "FilingDateInstant",
          }
        end

        #
        # idを設定します
        #
        def id_hash(consolidation, season)
          raise StandardError.new("idが設定されていません。") unless season
          year_duration = season == "Quarter" ? "YTDDuration_#{consolidation}" : "#{season}Duration_#{consolidation}"
          {
            reportable_segments_member: "[starts-with(@id,'Current#{year_duration}_') and not(substring-after(@id, 'ReportableSegmentsMember'))]"
          }
        end

        #
        # 証券コードを取得します
        #
        def find_securities_code(doc, consolidation)
          elm_code = doc.at_xpath("//jpdei_cor:SecurityCodeDEI")
          to_securities_code(elm_code)
        end

        #
        # 決算年を取得します
        #
        def find_year(doc, consolidation)
          elm_end = doc.at_xpath("//jpdei_cor:CurrentFiscalYearEndDateDEI")
          to_year(elm_end)
        end

        #
        # 決算月を取得します
        #
        def find_month(doc, consolidation)
          elm_end = doc.at_xpath("//jpdei_cor:CurrentFiscalYearEndDateDEI")
          to_month(elm_end)
        end

        #
        # 四半期を取得します
        #
        def find_quarter(doc, consolidation, context)
          # puts "//xbrli:xbrl/xbrli:context[@id='CurrentYearDuration_#{consolidation}' or @id='CurrentYTDDuration_#{consolidation}']/xbrli:period/xbrli:endDate"
          elm_end = doc.at_xpath("//xbrli:xbrl/xbrli:context[@id='CurrentYearDuration_#{consolidation}' or @id='CurrentYTDDuration_#{consolidation}' or @id='CurrentYearDuration' or @id='CurrentYTDDuration']/xbrli:period/xbrli:endDate")
          # puts "//xbrli:xbrl/xbrli:context[@id='#{context[:context_instant]}']/xbrli:period/xbrli:instant"
          elm_instant = doc.at_xpath("//xbrli:xbrl/xbrli:context[@id='#{context[:context_instant_consolidation]}' or @id='#{context[:context_instant]}']/xbrli:period/xbrli:instant")
          puts "elm_end : #{elm_end}"
          puts "elm_instant : #{elm_instant}"
          to_quarter(elm_end, elm_instant)
        end

        #
        # 四半期を取得します
        #
        def to_quarter(elm_end, elm_instant)
          raise StandardError.new("四半期を取得できません。") unless elm_end || elm_instant

          month_end = elm_end.content.split('-')[1].to_i
          month = elm_instant.content.split('-')[1].to_i

          if month <= month_end
            diff = month_end - month

            if diff < 3
              4
            elsif diff < 6
              3
            elsif diff < 9
              2
            else
              1
            end
          else
            diff = month - month_end

            if diff <= 3
              1
            elsif diff <= 6
              2
            elsif diff <= 9
              3
            else
              4
            end
          end
        end

        #
        # 有価証券報告書の勘定科目の値を取得します
        #
        def find_value_jp_cor(doc, item, context)

          find_value(doc, item, context) do |item, context|
            "//xbrli:xbrl/jpcrp_cor:#{item}[@contextRef='#{context}'] | //xbrli:xbrl/jppfs_cor:#{item}[@contextRef='#{context}'] | //xbrli:xbrl/jpdei_cor:#{item}[@contextRef='#{context}']"
          end
        end

        #
        # 勘定科目の値を取得します
        #
        def find_value(doc, item, context)
          # 配列の場合、いずれかに該当するもの
          if item[0].is_a? String
            xpath = item.map {|item| yield(item, context) }.join('|')
            elm = doc.at_xpath xpath
            elm.content if elm
          # 2次元配列の場合、先頭の配列から優先に
          elsif item[0].is_a? Array
            item.each do |item|
              xpath = item.map {|item| yield(item, context) }.join('|')
              elm = doc.at_xpath xpath
              return elm.content if elm
            end

            nil # 該当なし
          end
        end

        #
        # segmentを設定します
        #
        attr_accessor :segment_context_ref_name, :segment_english_name, :segment_sales, :segment_operating_profit
        def segment_hash
        {
          segment_context_ref_name: segment_context_ref_name,
          segment_english_name: segment_english_name,
          segment_sales: segment_sales,
          segment_operating_profit: segment_operating_profit
        }
        end

        #
        # 有価証券報告書の報告セグメントの値を取得します
        #
        def find_value_reportable_segments_member(doc, id)

          find_value_specified_id(doc, id) do |id|
            "//xbrli:xbrl/xbrli:context#{id}/xbrli:scenario/xbrldi:explicitMember[@dimension='jpcrp_cor:OperatingSegmentsAxis']"
          end
        end

        #
        # 報告セグメントの値を取得します
        #
        def find_value_specified_id(doc, id)
          xpath = yield(id)
          elm_array = Array.new()
          elm_array = doc.xpath xpath
          elm_array
        end
      end

    end
  end
end
