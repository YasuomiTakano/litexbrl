require 'spec_helper'
require 'support/nokogiri_helper'

module LiteXBRL
  module TDnet
    describe Summary2 do
      include NokogiriHelper

      let(:dir) { File.expand_path '../../data/tdnet/summary2', __FILE__ }

      describe ".context_hash" do
        let(:consolidation) { 'Consolidated' }
        let(:season) { 'AccumulatedQ1' }
        let(:quarter) { 1 }

        it "context" do
          context_hash = Summary2.send(:context_hash, consolidation, season)

          expect(context_hash[:context_duration]).to eq('CurrentAccumulatedQ1Duration_ConsolidatedMember_ResultMember')
          expect(context_hash[:context_instant]).to eq('CurrentAccumulatedQ1Instant')
          expect(context_hash[:context_forecast].call(quarter)).to eq('CurrentYearDuration_ConsolidatedMember_ForecastMember')
        end
      end

      describe ".read" do
        context '日本会計基準' do
          context "連結・第1四半期" do
            let(:xbrl) { Summary2.read doc("#{dir}/jp-cons-2014-q1.htm") }
            let(:summary) { xbrl[:summary] }
            let(:results_forecast) { xbrl[:results_forecast].first }

            it do
              expect(summary[:code]).to eq('3046')
              expect(summary[:year]).to eq(2014)
              expect(summary[:month]).to eq(8)
              expect(summary[:quarter]).to eq(1)

              expect(summary[:net_sales]).to eq(8168)
              expect(summary[:operating_income]).to eq(249)
              expect(summary[:ordinary_income]).to eq(219)
              expect(summary[:net_income]).to eq(70)
              expect(summary[:net_income_per_share]).to eq(2.92)

              expect(summary[:change_in_net_sales]).to eq(0.047)
              expect(summary[:change_in_operating_income]).to eq(-0.819)
              expect(summary[:change_in_ordinary_income]).to eq(-0.832)
              expect(summary[:change_in_net_income]).to eq(-0.909)

              expect(summary[:prior_net_sales]).to eq(7799)
              expect(summary[:prior_operating_income]).to eq(1377)
              expect(summary[:prior_ordinary_income]).to eq(1301)
              expect(summary[:prior_net_income]).to eq(766)
              expect(summary[:prior_net_income_per_share]).to eq(31.95)

              expect(summary[:change_in_prior_net_sales]).to eq(0.853)
              expect(summary[:change_in_prior_operating_income]).to eq(6.587)
              expect(summary[:change_in_prior_ordinary_income]).to eq(6.641)
              expect(summary[:change_in_prior_net_income]).to be_nil

              expect(results_forecast[:forecast_net_sales]).to eq(40600)
              expect(results_forecast[:forecast_operating_income]).to eq(6800)
              expect(results_forecast[:forecast_ordinary_income]).to eq(6850)
              expect(results_forecast[:forecast_net_income]).to eq(3900)
              expect(results_forecast[:forecast_net_income_per_share]).to eq(162.66)

              expect(results_forecast[:change_in_forecast_net_sales]).to eq(0.111)
              expect(results_forecast[:change_in_forecast_operating_income]).to eq(0.093)
              expect(results_forecast[:change_in_forecast_ordinary_income]).to eq(0.167)
              expect(results_forecast[:change_in_forecast_net_income]).to eq(0.141)
            end
          end

          context "連結・第4四半期" do
            let(:xbrl) { Summary2.read doc("#{dir}/jp-cons-2013-q4.htm") }
            let(:summary) { xbrl[:summary] }
            let(:results_forecast) { xbrl[:results_forecast].first }

            it do
              expect(summary[:code]).to eq('2408')
              expect(summary[:year]).to eq(2013)
              expect(summary[:month]).to eq(12)
              expect(summary[:quarter]).to eq(4)

              expect(summary[:net_sales]).to eq(4691)
              expect(summary[:operating_income]).to eq(759)
              expect(summary[:ordinary_income]).to eq(821)
              expect(summary[:net_income]).to eq(493)
              expect(summary[:net_income_per_share]).to eq(67.03)

              expect(summary[:change_in_net_sales]).to eq(-0.008)
              expect(summary[:change_in_operating_income]).to eq(-0.206)
              expect(summary[:change_in_ordinary_income]).to eq(-0.184)
              expect(summary[:change_in_net_income]).to eq(-0.147)

              expect(summary[:prior_net_sales]).to eq(4727)
              expect(summary[:prior_operating_income]).to eq(956)
              expect(summary[:prior_ordinary_income]).to eq(1005)
              expect(summary[:prior_net_income]).to eq(579)
              expect(summary[:prior_net_income_per_share]).to eq(79.73)

              expect(summary[:change_in_prior_net_sales]).to eq(0.008)
              expect(summary[:change_in_prior_operating_income]).to eq(0.036)
              expect(summary[:change_in_prior_ordinary_income]).to eq(0.039)
              expect(summary[:change_in_prior_net_income]).to eq(0.287)

              expect(results_forecast[:forecast_net_sales]).to eq(5064)
              expect(results_forecast[:forecast_operating_income]).to eq(509)
              expect(results_forecast[:forecast_ordinary_income]).to eq(530)
              expect(results_forecast[:forecast_net_income]).to eq(316)
              expect(results_forecast[:forecast_net_income_per_share]).to eq(42.91)

              expect(results_forecast[:change_in_forecast_net_sales]).to eq(0.079)
              expect(results_forecast[:change_in_forecast_operating_income]).to eq(-0.329)
              expect(results_forecast[:change_in_forecast_ordinary_income]).to eq(-0.354)
              expect(results_forecast[:change_in_forecast_net_income]).to eq(-0.359)
            end
          end
        end

=begin
        context '米国会計基準' do
          context '売上高：NetSales' do
            let(:xbrl) { Summary2.read doc("#{dir}/us-cons-2014-q1.xbrl") }

            it do
              expect(xbrl.code).to eq('7203')
              expect(xbrl.year).to eq(2014)
              expect(xbrl.month).to eq(3)
              expect(xbrl.quarter).to eq(1)

              expect(xbrl.net_sales).to eq(6255319)
              expect(xbrl.operating_income).to eq(663383)
              expect(xbrl.ordinary_income).to eq(724163)
              expect(xbrl.net_income).to eq(562194)
              expect(xbrl.net_income_per_share).to eq(177.45)
              expect(xbrl.forecast_net_sales).to eq(24000000)
              expect(xbrl.forecast_operating_income).to eq(1940000)
              expect(xbrl.forecast_ordinary_income).to eq(2030000)
              expect(xbrl.forecast_net_income).to eq(1480000)
              expect(xbrl.forecast_net_income_per_share).to eq(467.09)
            end
          end

          context '売上高：OperatingRevenues' do
            let(:xbrl) { Summary2.read doc("#{dir}/us-oprv-cons-2014-q1.xbrl") }

            it do
              expect(xbrl.code).to eq('9432')
              expect(xbrl.year).to eq(2014)
              expect(xbrl.month).to eq(3)
              expect(xbrl.quarter).to eq(1)

              expect(xbrl.net_sales).to eq(2609117)
              expect(xbrl.operating_income).to eq(348926)
              expect(xbrl.ordinary_income).to eq(356084)
              expect(xbrl.net_income).to eq(166717)
              expect(xbrl.net_income_per_share).to eq(141.29)
            end
          end

          context '売上高：NetSalesAndOperatingRevenuesUS' do
            let(:xbrl) { Summary2.read doc("#{dir}/us-nsoprv-cons-2014-q1.xbrl") }

            it do
              expect(xbrl.code).to eq('6758')
              expect(xbrl.year).to eq(2014)
              expect(xbrl.month).to eq(3)
              expect(xbrl.quarter).to eq(1)

              expect(xbrl.net_sales).to eq(1712712)
              expect(xbrl.operating_income).to eq(36357)
              expect(xbrl.ordinary_income).to eq(46253)
              expect(xbrl.net_income).to eq(3480)
              expect(xbrl.net_income_per_share).to eq(3.44)
            end
          end

          context '売上高：TotalRevenuesUS' do
            let(:xbrl) { Summary2.read doc("#{dir}/us-tr-ibit-cons-2013-q4.xbrl") }

            it do
              expect(xbrl.code).to eq('8604')
              expect(xbrl.year).to eq(2013)
              expect(xbrl.month).to eq(3)
              expect(xbrl.quarter).to eq(4)

              expect(xbrl.net_sales).to eq(2079943)
              expect(xbrl.operating_income).to eq(237730)
              expect(xbrl.ordinary_income).to eq(237730)
              expect(xbrl.net_income).to eq(107234)
              expect(xbrl.net_income_per_share).to eq(29.04)
            end
          end

          context '営業利益：OperatingIncome' do
            let(:xbrl) { Summary2.read doc("#{dir}/us-oi-cons-2014-q1.xbrl") }

            it do
              expect(xbrl.code).to eq('6752')
              expect(xbrl.year).to eq(2014)
              expect(xbrl.month).to eq(3)
              expect(xbrl.quarter).to eq(1)

              expect(xbrl.net_sales).to eq(1824515)
              expect(xbrl.operating_income).to eq(64201)
              expect(xbrl.ordinary_income).to eq(122612)
              expect(xbrl.net_income).to eq(107831)
              expect(xbrl.net_income_per_share).to eq(46.65)
            end
          end

          context '営業利益：BasicNetIncomePerShareUS' do
            let(:xbrl) { Summary2.read doc("#{dir}/us-bnip-cons-2014-q1.xbrl") }

            it do
              expect(xbrl.code).to eq('7267')
              expect(xbrl.year).to eq(2014)
              expect(xbrl.month).to eq(3)
              expect(xbrl.quarter).to eq(1)

              expect(xbrl.net_sales).to eq(2834095)
              expect(xbrl.operating_income).to eq(184963)
              expect(xbrl.ordinary_income).to eq(172035)
              expect(xbrl.net_income).to eq(122499)
              expect(xbrl.net_income_per_share).to eq(67.97)
            end
          end

          context '営業利益：IncomeBeforeIncomeTaxesUS' do
            let(:xbrl) { Summary2.read doc("#{dir}/us-tr-ibit-cons-2013-q4.xbrl") }

            it do
              expect(xbrl.code).to eq('8604')
              expect(xbrl.year).to eq(2013)
              expect(xbrl.month).to eq(3)
              expect(xbrl.quarter).to eq(4)

              expect(xbrl.net_sales).to eq(2079943)
              expect(xbrl.operating_income).to eq(237730)
              expect(xbrl.ordinary_income).to eq(237730)
              expect(xbrl.net_income).to eq(107234)
              expect(xbrl.net_income_per_share).to eq(29.04)
            end
          end

          context '経常利益：IncomeFromContinuingOperationsBeforeIncomeTaxesUS' do
            let(:xbrl) { Summary2.read doc("#{dir}/us-ifco-cons-2013-q4.xbrl") }

            it do
              expect(xbrl.code).to eq('6502')
              expect(xbrl.year).to eq(2013)
              expect(xbrl.month).to eq(3)
              expect(xbrl.quarter).to eq(4)

              expect(xbrl.net_sales).to eq(5800281)
              expect(xbrl.operating_income).to eq(194316)
              expect(xbrl.ordinary_income).to eq(155553)
              expect(xbrl.net_income).to eq(77533)
              expect(xbrl.net_income_per_share).to eq(18.31)
            end
          end

          context '純利益：IncomeBeforeMinorityInterestUS' do
            let(:xbrl) { Summary2.read doc("#{dir}/us-ibmi-cons-2013-q4.xbrl") }

            it do
              expect(xbrl.code).to eq('6981')
              expect(xbrl.year).to eq(2013)
              expect(xbrl.month).to eq(3)
              expect(xbrl.quarter).to eq(4)

              expect(xbrl.net_sales).to eq(681021)
              expect(xbrl.operating_income).to eq(58636)
              expect(xbrl.ordinary_income).to eq(59534)
              expect(xbrl.net_income).to eq(42386)
              expect(xbrl.net_income_per_share).to eq(200.81)
            end
          end
        end
=end

        context 'IFRS' do
          let(:xbrl) { Summary2.read doc("#{dir}/ifrs-cons-2013-q4.htm") }
          let(:summary) { xbrl[:summary] }
          let(:results_forecast) { xbrl[:results_forecast].first }

          it do
            expect(summary[:code]).to eq('8923')
            expect(summary[:year]).to eq(2013)
            expect(summary[:month]).to eq(11)
            expect(summary[:quarter]).to eq(4)

            expect(summary[:net_sales]).to eq(35070)
            expect(summary[:operating_income]).to eq(3909)
            expect(summary[:ordinary_income]).to eq(3217)
            expect(summary[:net_income]).to eq(2003)
            expect(summary[:net_income_per_share]).to eq(42.99)

            expect(summary[:change_in_net_sales]).to eq(0.449)
            expect(summary[:change_in_operating_income]).to eq(0.369)
            expect(summary[:change_in_ordinary_income]).to eq(0.45)
            expect(summary[:change_in_net_income]).to eq(0.367)

            expect(summary[:prior_net_sales]).to eq(24195)
            expect(summary[:prior_operating_income]).to eq(2856)
            expect(summary[:prior_ordinary_income]).to eq(2218)
            expect(summary[:prior_net_income]).to eq(1465)
            expect(summary[:prior_net_income_per_share]).to eq(32.07)

#            expect(xbrl.change_in_prior_net_sales).to eq(0.008)
#            expect(xbrl.change_in_prior_operating_income).to eq(0.036)
#            expect(xbrl.change_in_prior_ordinary_income).to eq(0.039)
#            expect(xbrl.change_in_prior_net_income).to eq(0.287)

            expect(results_forecast[:forecast_net_sales]).to eq(41817)
            expect(results_forecast[:forecast_operating_income]).to eq(4618)
            expect(results_forecast[:forecast_ordinary_income]).to eq(3800)
            expect(results_forecast[:forecast_net_income]).to eq(2309)
            expect(results_forecast[:forecast_net_income_per_share]).to eq(47.82)

            expect(results_forecast[:change_in_forecast_net_sales]).to eq(0.192)
            expect(results_forecast[:change_in_forecast_operating_income]).to eq(0.181)
            expect(results_forecast[:change_in_forecast_ordinary_income]).to eq(0.181)
            expect(results_forecast[:change_in_forecast_net_income]).to eq(0.153)
          end
        end
      end
=begin
      describe ".read_string" do
        let(:xbrl) { Summary2.read doc_string(File.read("#{dir}/ja-cons-2013-q1.xbrl")) }

        it do
          expect(xbrl.year).to eq(2013)
        end
      end

      describe "#attributes" do
        it do
          summary = Summary2.new
          summary.code = 1111
          summary.year = 2013
          summary.month = 3
          summary.quarter = 1
          summary.net_sales = 100
          summary.operating_income = 10
          summary.ordinary_income = 11
          summary.net_income = 6
          summary.net_income_per_share = 123.1

          attr = summary.attributes

          expect(attr[:code]).to eq(1111)
          expect(attr[:year]).to eq(2013)
          expect(attr[:quarter]).to eq(1)
          expect(attr[:net_sales]).to eq(100)
          expect(attr[:operating_income]).to eq(10)
          expect(attr[:ordinary_income]).to eq(11)
          expect(attr[:net_income]).to eq(6)
          expect(attr[:net_income_per_share]).to eq(123.1)
        end
      end

      describe "#attributes_results_forecast" do
        context '第1四半期' do
          let(:quarter) { 1 }

          it '今期予想' do
            summary = Summary2.new
            summary.code = 1111
            summary.year = 2013
            summary.month = 3
            summary.quarter = quarter
            summary.forecast_net_sales = 100
            summary.forecast_operating_income = 10
            summary.forecast_ordinary_income = 11
            summary.forecast_net_income = 6
            summary.forecast_net_income_per_share = 123.1
            attr = summary.attributes_results_forecast

            expect(attr[:code]).to eq(1111)
            expect(attr[:year]).to eq(2013)
            expect(attr[:quarter]).to eq(1)
            expect(attr[:forecast_net_sales]).to eq(100)
            expect(attr[:forecast_operating_income]).to eq(10)
            expect(attr[:forecast_ordinary_income]).to eq(11)
            expect(attr[:forecast_net_income]).to eq(6)
            expect(attr[:forecast_net_income_per_share]).to eq(123.1)
          end
        end

        context '第4四半期' do
          let(:quarter) { 4 }

          it '来期予想' do
            summary = Summary2.new
            summary.year = 2013
            summary.quarter = quarter
            attr = summary.attributes_results_forecast

            expect(attr[:year]).to eq(2014)
          end
        end
      end
=end

      describe '.read_company' do
        context '日本会計基準' do
          let(:xbrl) { Summary2.parse_company str("#{dir}/jp-cons-2014-q1.htm") }

          it do
            expect(xbrl.company_name).to eq("株式会社 ジェイアイエヌ")
          end
        end
      end

      describe "#attributes_company" do
        it do
          summary = Summary2.new
          summary.code = "1111"
          summary.company_name = "aaa"

          attr = summary.attributes_company

          expect(attr[:code]).to eq("1111")
          expect(attr[:company_name]).to eq("aaa")
        end
      end

    end
  end
end