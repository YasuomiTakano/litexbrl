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

          year_duration = season == "FY" ? "YearDuration" : "YTDDuration"
          {
            context_duration: "Current#{year_duration}",
            context_consolidation: "#{consolidation}",
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
          year_duration = season == "Quarter" ? "YTDDuration" : "#{season}Duration"
          {
            reportable_segments_member: "[starts-with(@id,'Current#{year_duration}_') and not(substring-after(@id, 'ReportableSegmentsMember')) and (contains(@id, '-asr_') or contains(@id, '-q1r_') or contains(@id, '-q2r_') or contains(@id, '-q3r_'))]"
          }
        end

        #
        # ネームスペースを取得します
        #
        def find_namespaces(doc)
          doc.namespaces.keys.map do |key|
            key.split(":")[1]
          end
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
          elm_end = doc.at_xpath("//xbrli:xbrl/xbrli:context[@id='CurrentYearDuration_#{consolidation}' or @id='CurrentYTDDuration_#{consolidation}' or @id='CurrentYearDuration' or @id='CurrentYTDDuration']/xbrli:period/xbrli:endDate")
          elm_instant = doc.at_xpath("//xbrli:xbrl/xbrli:context[@id='#{context[:context_instant_consolidation]}' or @id='#{context[:context_instant]}']/xbrli:period/xbrli:instant")
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
        def find_value_jp_cor(doc, item, context, context_consolidation)
          context_array = ["#{context}", "#{context}_Consolidated", "#{context}_NonConsolidatedMember"]
          namespaces_array = ['jpcrp_cor', 'jppfs_cor', 'jpdei_cor']
          xpath_array = (find_namespaces(doc) & namespaces_array).map do |ns|
            item.map do |i|
              context_array.map do |c|
                "//xbrli:xbrl/#{ns}:#{i}[@contextRef='#{c}']"
              end
            end
          end.flatten
          find_value(xpath_array, doc)
        end

        def find_value_jp_cor_segment(doc, item, context_ref_name, context, context_consolidation)
          context_array = ["#{context}", "#{context}_Consolidated", "#{context}_NonConsolidatedMember"]
          namespaces_array = ['jpcrp_cor', 'jppfs_cor', 'jpdei_cor']

          xpath_array = (find_namespaces(doc) & namespaces_array).map do |ns|
            item.map do |i|
              context_array.map do |c|
                "//xbrli:xbrl/#{ns}:#{i}[starts-with(@contextRef,'#{c}_') and contains(@contextRef, '#{context_ref_name}')]"
              end
            end
          end.flatten
          find_value(xpath_array, doc)
        end

        #
        # 勘定科目の値を取得します
        #
        def find_value(xpath_array, doc)
          xpath_array.lazy.map do |x|
            doc.at_xpath(x)&.content
          end.find do |content|
            content != nil
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
          namespaces_array = ['xbrldi']
          (find_namespaces(doc) & namespaces_array).map do |ns|
            find_value_specified_id(doc, id) do |id|
              "//xbrli:xbrl/xbrli:context#{id}/xbrli:scenario/#{ns}:explicitMember[@dimension='jpcrp_cor:OperatingSegmentsAxis']"
            end
          end.flatten
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
