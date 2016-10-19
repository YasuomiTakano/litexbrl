require 'spec_helper'
require 'support/nokogiri_helper'

module LiteXBRL
  module Edinet
    describe SecurityReport do
      include NokogiriHelper

      let(:dir) { File.expand_path '../../data/edinet', __FILE__ }
      describe ".read doc" do
        context '日本会計基準' do
          context "四半期報告書" do
            let(:xbrl) { SecurityReport.read doc("#{dir}/quarter.xml") }
            let(:security_report) { xbrl[:security_report] }
            it do
              expect(security_report[:code]).to eq '1111'
              expect(security_report[:year]).to eq 2016
              expect(security_report[:month]).to eq 12
              expect(security_report[:quarter]).to eq 4
              expect(security_report[:net_sales]).to eq '66707000000'
              expect(security_report[:consolidation]).to eq 1
              expect(security_report[:operating_income]).to eq '8690000000'
              expect(security_report[:ordinary_income]).to eq '8349000000'
              expect(security_report[:document_title_cover_page]).to eq '四半期報告書'
              expect(security_report[:fiscal_year_cover_page]).to eq '第0期第2四半期(自  平成0年0月0日  至  平成1年1月1日)'
              expect(security_report[:company_name]).to eq 'テスト株式会社'
              expect(security_report[:filing_date]).to eq '2016-08-09'
              expect(security_report[:current_fiscal_year_start_date]).to eq '2016-01-01'
              expect(security_report[:current_fiscal_year_end_date]).to eq '2016-12-31'
              expect(security_report[:current_period_end_date]).to eq '2016-06-30'
              expect(security_report[:type_of_current_period]).to eq 'Q2'

              expect(security_report[:segments][0][:segment_context_ref_name]).to eq 'jpcrp040300-q2r_E05041-000InternetInfrastructureReportableSegmentsMember'
              expect(security_report[:segments][0][:segment_english_name]).to eq 'InternetInfrastructure'
              expect(security_report[:segments][0][:segment_sales]).to eq '31206000000'
              expect(security_report[:segments][0][:segment_operating_profit]).to eq '2986000000'
              expect(security_report[:segments][1][:segment_context_ref_name]).to eq 'jpcrp040300-q2r_E05041-000OnlineAdvertisingAndMediaReportableSegmentsMember'
              expect(security_report[:segments][1][:segment_english_name]).to eq 'OnlineAdvertisingAndMedia'
              expect(security_report[:segments][1][:segment_sales]).to eq '21868000000'
              expect(security_report[:segments][1][:segment_operating_profit]).to eq '666000000'
              expect(security_report[:segments][2][:segment_context_ref_name]).to eq 'jpcrp040300-q2r_E05041-000InternetSecuritiesReportableSegmentsMember'
              expect(security_report[:segments][2][:segment_english_name]).to eq 'InternetSecurities'
              expect(security_report[:segments][2][:segment_sales]).to eq '14542000000'
              expect(security_report[:segments][2][:segment_operating_profit]).to eq '5397000000'
              expect(security_report[:segments][3][:segment_context_ref_name]).to eq 'jpcrp040300-q2r_E05041-000MobileEntertainmentReportableSegmentsMember'
              expect(security_report[:segments][3][:segment_english_name]).to eq 'MobileEntertainment'
              expect(security_report[:segments][3][:segment_sales]).to eq '1262000000'
              expect(security_report[:segments][3][:segment_operating_profit]).to eq '-292000000'
              expect(security_report[:segments][4][:segment_context_ref_name]).to eq 'jpcrp040300-q2r_E05041-000IncubationReportableSegmentsMember'
              expect(security_report[:segments][4][:segment_english_name]).to eq 'Incubation'
              expect(security_report[:segments][4][:segment_sales]).to eq '32000000'
              expect(security_report[:segments][4][:segment_operating_profit]).to eq '-85000000'

            end
          end
        end
      end

    end
  end
end
