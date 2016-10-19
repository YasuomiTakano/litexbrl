require 'spec_helper'
require 'support/nokogiri_helper'

module LiteXBRL
  module Edinet
    describe FinancialInformation do
      include NokogiriHelper
      let(:dir) { File.expand_path '../../data/edinet', __FILE__ }

      describe 'methods test' do

        describe '#find_namespaces' do
          context 'japan accounting standards' do
            let(:namespaces_array){['hoge', 'fuga']}
            example 'when you get the name space' do
              expect(FinancialInformation.send(:find_namespaces, doc("#{dir}/find_namespaces_test.xml"))).to match_array namespaces_array
            end
          end
        end


        describe '#find_value_jp_cor' do
          context 'japan accounting standards' do
            let(:item){['Result1']}
            let(:context){'Context'}
            let(:context_consolidation){'Consolidated'}
            example 'when you get the net sales' do
              expect(FinancialInformation.send(:find_value_jp_cor, doc("#{dir}/find_value_jp_cor_test.xml"), item, context, context_consolidation)).to eq '6670'
            end
          end
          context 'japan accounting standards' do
            let(:item){['Result2']}
            let(:context){'Context'}
            let(:context_consolidation){'Consolidated'}
            example 'when you do not get the net sales' do
              expect(FinancialInformation.send(:find_value_jp_cor, doc("#{dir}/find_value_jp_cor_test.xml"), item, context, context_consolidation)).to eq nil
            end
          end
        end


        describe '#find_value_jp_cor_segment' do
          context 'japan accounting standards' do
            let(:item){['Result1']}
            let(:context_ref_name){'SegmentsMemberName'}
            let(:context){'Context'}
            let(:context_consolidation){'Consolidated'}
            example 'when you get a segment of net sales' do
              expect(FinancialInformation.send(:find_value_jp_cor_segment, doc("#{dir}/find_value_jp_cor_segment_test.xml"), item, context_ref_name, context, context_consolidation)).to eq '3120'
            end
          end
        end


        describe '#find_value' do
          context 'japan accounting standards' do
            let(:xpath_array){["//xbrli:xbrl/jpcrp_cor:Result1[@contextRef='Context']"]}
            example 'when you get the net sales by specifying the XPath' do
              expect(FinancialInformation.send(:find_value, xpath_array, doc("#{dir}/find_value_test.xml"))).to eq '7671'
            end
          end
        end


        describe '#find_value_reportable_segments_member' do
          context 'japan accounting standards' do
            let(:result_array){[
              '<xbrldi:explicitMember dimension="jpcrp_cor:OperatingSegmentsAxis">SegmentsMember1</xbrldi:explicitMember>',
              '<xbrldi:explicitMember dimension="jpcrp_cor:OperatingSegmentsAxis">SegmentsMember2</xbrldi:explicitMember>',
              '<xbrldi:explicitMember dimension="jpcrp_cor:OperatingSegmentsAxis">SegmentsMember3</xbrldi:explicitMember>',
              '<xbrldi:explicitMember dimension="jpcrp_cor:OperatingSegmentsAxis">SegmentsMember4</xbrldi:explicitMember>',
              '<xbrldi:explicitMember dimension="jpcrp_cor:OperatingSegmentsAxis">SegmentsMember5</xbrldi:explicitMember>']}

            let(:id){"[starts-with(@id,'CurrentYTDDuration_') and not(substring-after(@id, 'ReportableSegmentsMember')) and (contains(@id, '-asr_') or contains(@id, '-q1r_') or contains(@id, '-q2r_') or contains(@id, '-q3r_'))]"}

            example 'when you get the OperatingSegmentsAxis' do
              expect(FinancialInformation.send(:find_value_reportable_segments_member, doc("#{dir}/find_value_reportable_segments_member_test.xml"), id).map(&:to_s)).to eq result_array
            end
          end
        end

        describe '#context_hash' do
          context 'japan accounting standards' do
            let(:consolidation){'Consolidated'}
            let(:season_fy){'FY'}
            let(:season_q1){'Q1'}
            let(:result_array_fy){{
               :context_duration=>"CurrentYearDuration",
               :context_consolidation=>"Consolidated",
               :context_prior_duration=>"PriorYearDuration",
               :context_instant=>"CurrentYearInstant",
               :context_instant_consolidation=>"CurrentYearInstant_Consolidated",
               :filing_date_instant=>"FilingDateInstant"}}

            let(:result_array_q1){{
               :context_duration=>"CurrentYTDDuration",
               :context_consolidation=>"Consolidated",
               :context_prior_duration=>"PriorYTDDuration",
               :context_instant=>"CurrentQuarterInstant",
               :context_instant_consolidation=>"CurrentQuarterInstant_Consolidated",
               :filing_date_instant=>"FilingDateInstant"}}
            example 'when you get the context hash of the year' do
              expect(FinancialInformation.send(:context_hash, consolidation, season_fy)).to eq result_array_fy
            end

            example 'when you get a quarter of context hash' do
              expect(FinancialInformation.send(:context_hash, consolidation, season_q1)).to eq result_array_q1
            end
          end
        end

      end

    end
  end
end
