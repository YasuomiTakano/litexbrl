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
            let(:xbrl) { SecurityReport.read doc("#{dir}/9449_q.xbrl") }
            let(:security_report) { xbrl[:security_report] }
            it do
              expect(security_report[:code]).to eq "9449"
              expect(security_report[:year]).to eq 2016
              expect(security_report[:month]).to eq 12
              expect(security_report[:quarter]).to eq 4
              expect(security_report[:net_sales]).to eq "66707000000"
              expect(security_report[:consolidation]).to eq 1
              expect(security_report[:operating_income]).to eq "8690000000"
              expect(security_report[:ordinary_income]).to eq "8349000000"
              expect(security_report[:document_title_cover_page]).to eq "四半期報告書"
              expect(security_report[:fiscal_year_cover_page]).to eq "第26期第２四半期(自  平成28年４月１日  至  平成28年６月30日)"
              expect(security_report[:company_name]).to eq "GMOインターネット株式会社"
              expect(security_report[:filing_date]).to eq "2016-08-09"
              expect(security_report[:current_fiscal_year_start_date]).to eq "2016-01-01"
              expect(security_report[:current_fiscal_year_end_date]).to eq "2016-12-31"
              expect(security_report[:current_period_end_date]).to eq "2016-06-30"
              expect(security_report[:type_of_current_period]).to eq "Q2"
            end
          end
        end
      end

    end
  end
end
