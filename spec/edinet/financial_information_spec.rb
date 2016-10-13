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
            let(:namespaces_array){['link', 'jpdei_cor', 'xbrldi', 'jpcrp040300-q2r_E05041-000', 'xlink', 'jpcrp_cor', 'xbrli', 'jppfs_cor', 'iso4217', 'xsi']}
            example 'when you get the name space' do
              expect(FinancialInformation.send(:find_namespaces, doc("#{dir}/9449_q.xbrl"))).to match_array namespaces_array
            end
          end
        end


        describe '#find_value_jp_cor' do
          context 'japan accounting standards' do
            let(:item){['NetSales', 'NetSalesSummaryOfBusinessResults', 'RevenueIFRSSummaryOfBusinessResults']}
            let(:context){'CurrentYTDDuration'}
            let(:context_consolidation){'Consolidated'}
            example 'when you get the net sales' do
              expect(FinancialInformation.send(:find_value_jp_cor, doc("#{dir}/9449_q.xbrl"), item, context, context_consolidation)).to eq '66707000000'
            end
          end
        end


        describe '#find_value_jp_cor_segment' do
          context 'japan accounting standards' do
            let(:item){['NetSales', 'NetSalesSummaryOfBusinessResults', 'RevenueIFRSSummaryOfBusinessResults']}
            let(:context_ref_name){'jpcrp040300-q2r_E05041-000InternetInfrastructureReportableSegmentsMember'}
            let(:context){'CurrentYTDDuration'}
            let(:context_consolidation){'Consolidated'}
            example 'when you get a segment of net sales' do
              expect(FinancialInformation.send(:find_value_jp_cor_segment, doc("#{dir}/9449_q.xbrl"), item, context_ref_name, context, context_consolidation)).to eq '31206000000'
            end
          end
        end


        describe '#find_value' do
          context 'japan accounting standards' do
            let(:xpath_array){["//xbrli:xbrl/jpcrp_cor:NetSalesSummaryOfBusinessResults[@contextRef='CurrentYTDDuration']"]}
            example 'when you get the net sales by specifying the XPath' do
              expect(FinancialInformation.send(:find_value, xpath_array, doc("#{dir}/9449_q.xbrl"))).to eq '66707000000'
            end
          end
        end


        describe '#find_value_reportable_segments_member' do
          context 'japan accounting standards' do
            let(:result_array){['<xbrldi:explicitMember dimension="jpcrp_cor:OperatingSegmentsAxis">jpcrp040300-q2r_E05041-000:InternetInfrastructureReportableSegmentsMember</xbrldi:explicitMember>', '<xbrldi:explicitMember dimension="jpcrp_cor:OperatingSegmentsAxis">jpcrp040300-q2r_E05041-000:OnlineAdvertisingAndMediaReportableSegmentsMember</xbrldi:explicitMember>', '<xbrldi:explicitMember dimension="jpcrp_cor:OperatingSegmentsAxis">jpcrp040300-q2r_E05041-000:InternetSecuritiesReportableSegmentsMember</xbrldi:explicitMember>', '<xbrldi:explicitMember dimension="jpcrp_cor:OperatingSegmentsAxis">jpcrp040300-q2r_E05041-000:MobileEntertainmentReportableSegmentsMember</xbrldi:explicitMember>', '<xbrldi:explicitMember dimension="jpcrp_cor:OperatingSegmentsAxis">jpcrp040300-q2r_E05041-000:IncubationReportableSegmentsMember</xbrldi:explicitMember>']}

            let(:id){"[starts-with(@id,'CurrentYTDDuration_') and not(substring-after(@id, 'ReportableSegmentsMember')) and (contains(@id, '-asr_') or contains(@id, '-q1r_') or contains(@id, '-q2r_') or contains(@id, '-q3r_'))]"}

            example 'when you get the OperatingSegmentsAxis' do
              expect(FinancialInformation.send(:find_value_reportable_segments_member, doc("#{dir}/9449_q.xbrl"), id).map(&:to_s)).to eq result_array
            end
          end
        end
      end

    end
  end
end
