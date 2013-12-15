require 'spec_helper'
require 'support/nokogiri_helper'

module LiteXBRL
  module TDnet
    describe ResultsForecast do
      include NokogiriHelper

      let(:dir) { File.expand_path '../../data/tdnet/results_forecast', __FILE__ }

      describe ".parse" do
        context '日本会計基準' do
          context "連結" do
            let(:xbrl) { ResultsForecast.parse("#{dir}/jp-cons-2012.xbrl") }

            it do
              expect(xbrl.code).to eq('4368')
              expect(xbrl.year).to eq(2012)
              expect(xbrl.month).to eq(3)
#              expect(xbrl.quarter).to eq(4)

              expect(xbrl.forecast_net_sales).to eq(28300)
              expect(xbrl.forecast_operating_income).to eq(3850)
              expect(xbrl.forecast_ordinary_income).to eq(3700)
              expect(xbrl.forecast_net_income).to eq(2400)
              expect(xbrl.forecast_net_income_per_share).to eq(380.87)
            end
          end
        end

        context '米国会計基準' do
          context '連結' do
            let(:xbrl) { ResultsForecast.parse("#{dir}/us-cons-2014.xbrl") }

            it do
              expect(xbrl.code).to eq('6594')
              expect(xbrl.year).to eq(2014)
              expect(xbrl.month).to eq(3)
#              expect(xbrl.quarter).to eq(4)

              expect(xbrl.forecast_net_sales).to eq(850000)
              expect(xbrl.forecast_operating_income).to eq(80000)
              expect(xbrl.forecast_ordinary_income).to eq(78000)
              expect(xbrl.forecast_net_income).to eq(55000)
              expect(xbrl.forecast_net_income_per_share).to eq(404.26)
            end
          end
        end

        context 'IFRS' do
          context '連結' do
            let(:xbrl) { ResultsForecast.parse("#{dir}/ifrs-cons-2014.xbrl") }

            it do
              expect(xbrl.code).to eq('6779')
              expect(xbrl.year).to eq(2014)
              expect(xbrl.month).to eq(3)
#              expect(xbrl.quarter).to eq(1)

              expect(xbrl.forecast_net_sales).to eq(51000)
              expect(xbrl.forecast_operating_income).to eq(700)
              expect(xbrl.forecast_ordinary_income).to eq(500)
              expect(xbrl.forecast_net_income).to eq(400)
              expect(xbrl.forecast_net_income_per_share).to eq(20.38)
            end
          end
        end
      end

      describe "#attributes" do
        it do
          results_forecast = ResultsForecast.new
          results_forecast.code = 1111
          results_forecast.year = 2013
          results_forecast.month = 3
          results_forecast.quarter = 1
          results_forecast.forecast_net_sales = 100
          results_forecast.forecast_operating_income = 10
          results_forecast.forecast_ordinary_income = 11
          results_forecast.forecast_net_income = 6
          results_forecast.forecast_net_income_per_share = 123.1

          attr = results_forecast.attributes

          expect(attr[:code]).to eq(1111)
          expect(attr[:year]).to eq(2013)
          expect(attr[:month]).to eq(3)
          expect(attr[:quarter]).to eq(1)
          expect(attr[:forecast_net_sales]).to eq(100)
          expect(attr[:forecast_operating_income]).to eq(10)
          expect(attr[:forecast_ordinary_income]).to eq(11)
          expect(attr[:forecast_net_income]).to eq(6)
          expect(attr[:forecast_net_income_per_share]).to eq(123.1)
        end
      end

    end
  end
end