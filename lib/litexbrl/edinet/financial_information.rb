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
          raise StandardError.new("通期・四半期が設定されていません。") unless season

          puts year_duration = "#{season}Duration_#{consolidation}"
          # puts year_duration = season == "Year" ? "YearDuration_#{consolidation}" : "YTDDuration_#{consolidation}"
          {
            context_duration: "Current#{season}Duration_#{consolidation}",
            context_prior_duration: "Prior#{season}Duration_#{consolidation}",
            context_instant: "Current#{season}Instant_#{consolidation}",
            context_forecast: ->(quarter) { quarter == 4 ? "Next#{year_duration}" : "Current#{year_duration}"},
          }
        end

        #
        # 証券コードを取得します
        #
        def find_securities_code(doc, consolidation)
          elm_code = doc.at_xpath("//jpdei_cor:SecurityCodeDEI")
          to_securities_code(elm_code)
          # code = to_securities_code(elm_code)
          # puts "code : #{code}"
        end

        #
        # 決算年を取得します
        #
        def find_year(doc, consolidation)
          elm_end = doc.at_xpath("//jpdei_cor:CurrentFiscalYearEndDateDEI")
          to_year(elm_end)
          # year = to_year(elm_end)
          # puts "year : #{year}"
        end

        #
        # 決算月を取得します
        #
        def find_month(doc, consolidation)
          elm_end = doc.at_xpath("//jpdei_cor:CurrentFiscalYearEndDateDEI")
          to_month(elm_end)
          # month = to_month(elm_end)
          # puts "month : #{month}"
        end

        #
        # 四半期を取得します
        #
        def find_quarter(doc, consolidation, context)
          # [@id='CurrentYearDuration' or @id='CurrentYTDDuration']
          elm_end = doc.at_xpath("//xbrli:xbrl/xbrli:context[@id='CurrentYearDuration_#{consolidation}' or @id='CurrentYTDDuration_#{consolidation}']/xbrli:period/xbrli:endDate")
          elm_instant = doc.at_xpath("//xbrli:xbrl/xbrli:context[@id='#{context[:context_instant]}']/xbrli:period/xbrli:instant")
          to_quarter(elm_end, elm_instant)
          # quarter = to_quarter(elm_end, elm_instant)
          # puts "elm_end : #{elm_end}"
          # puts "elm_instant : #{elm_instant}"
          # puts "quarter : #{quarter}"


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
        def find_value_tse_t_ed(doc, item, context)

          find_value(doc, item, context) do |item, context|
            "//xbrli:xbrl/jpcrp_cor:#{item}[@contextRef='#{context}' or @contextRef='FilingDateInstant'] | //xbrli:xbrl/jppfs_cor:#{item}[@contextRef='#{context}' or @contextRef='FilingDateInstant'] | //xbrli:xbrl/jpdei_cor:#{item}[@contextRef='#{context}' or @contextRef='FilingDateInstant']"
                        # "//xbrli:xbrl/tse-t-ed:#{item}[@contextRef='FilingDateInstant']"

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
