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
          cons = doc.at_xpath("//xbrli:xbrl/xbrli:context[@id='CurrentYearDuration']/xbrli:entity/xbrli:identifier")
          non_cons = doc.at_xpath("//xbrli:xbrl/xbrli:context[@id='CurrentYearDuration_NonConsolidatedMember']/xbrli:entity/xbrli:identifier")

          if cons
            "Consolidated"
          elsif non_cons
            "NonConsolidated"
          else
            raise StandardError.new("連結・非連結ともに該当しません。")
          end
        end

        #
        # contextを設定します
        #
        def context_hash(consolidation, season)
          raise StandardError.new("通期・四半期が設定されていません。") unless season

          year_duration = "Year#{consolidation}Duration"

          {
            context_duration: "Current#{season}#{consolidation}Duration",
            context_prior_duration: "Prior#{season}#{consolidation}Duration",
            context_instant: "Current#{season}#{consolidation}Instant",
            context_forecast: ->(quarter) { quarter == 4 ? "Next#{year_duration}" : "Current#{year_duration}"},
          }
        end

        #
        # 証券コードを取得します
        #
        def find_securities_code(doc, consolidation)
          elm_code = doc.at_xpath("//xbrli:xbrl/xbrli:context[@id='CurrentYear#{consolidation}Duration']/xbrli:entity/xbrli:identifier")
          to_securities_code(elm_code)
        end

        #
        # 決算年を取得します
        #
        def find_year(doc, consolidation)
          elm_end = doc.at_xpath("//xbrli:xbrl/xbrli:context[@id='CurrentYear#{consolidation}Duration']/xbrli:period/xbrli:endDate")
          to_year(elm_end)
        end

        #
        # 決算月を取得します
        #
        def find_month(doc, consolidation)
          elm_end = doc.at_xpath("//xbrli:xbrl/xbrli:context[@id='CurrentYear#{consolidation}Duration']/xbrli:period/xbrli:endDate")
          to_month(elm_end)
        end

        #
        # 四半期を取得します
        #
        def find_quarter(doc, consolidation, context)
          elm_end = doc.at_xpath("//xbrli:xbrl/xbrli:context[@id='CurrentYear#{consolidation}Duration']/xbrli:period/xbrli:endDate")
          elm_instant = doc.at_xpath("//xbrli:xbrl/xbrli:context[@id='#{context[:context_instant]}']/xbrli:period/xbrli:instant")
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
        # 決算短信サマリの勘定科目の値を取得します
        #
        def find_value_tse_t_ed(doc, item, context)
          find_value(doc, item, context) do |item, context|
            "//xbrli:xbrl/tse-t-ed:#{item}[@contextRef='#{context}']"
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
      end

    end
  end
end
