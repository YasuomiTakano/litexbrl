module LiteXBRL
  module Edinet
    module SecurityReportAttribute

      attr_accessor :code, :year, :month, :quarter, :consolidation,
        :net_sales, :operating_income, :ordinary_income, :net_income, :net_income_per_share,
        :change_in_net_sales, :change_in_operating_income, :change_in_ordinary_income, :change_in_net_income,
        :prior_net_sales, :prior_operating_income, :prior_ordinary_income, :prior_net_income, :prior_net_income_per_share,
        :change_in_prior_net_sales, :change_in_prior_operating_income, :change_in_prior_ordinary_income, :change_in_prior_net_income,
        :forecast_net_sales, :forecast_operating_income, :forecast_ordinary_income, :forecast_net_income, :forecast_net_income_per_share,
        :change_in_forecast_net_sales, :change_in_forecast_operating_income, :change_in_forecast_ordinary_income, :change_in_forecast_net_income,
        :owners_equity, :number_of_shares, :number_of_treasury_stock, :net_assets_per_share, :document_title_cover_page, :fiscal_year_cover_page, :current_fiscal_year_end_date, :company_name, :filing_date, :start_date, :end_date, :number_of_employees, :segments, :segment_context_ref_name, :segment_english_name, :segment_sales, :egment_operating_profit

      def attributes
        {
          code: code,
          year: year,
          month: month,
          quarter: quarter,
          net_sales: net_sales,
          consolidation: consolidation,
          operating_income: operating_income,
          ordinary_income: ordinary_income,
          net_income: net_income,
          net_income_per_share: net_income_per_share,
          change_in_net_sales: change_in_net_sales,
          change_in_operating_income: change_in_operating_income,
          change_in_ordinary_income: change_in_ordinary_income,
          change_in_net_income: change_in_net_income,
          prior_net_sales: prior_net_sales,
          prior_operating_income: prior_operating_income,
          prior_ordinary_income: prior_ordinary_income,
          prior_net_income: prior_net_income,
          prior_net_income_per_share: prior_net_income_per_share,
          change_in_prior_net_sales: change_in_prior_net_sales,
          change_in_prior_operating_income: change_in_prior_operating_income,
          change_in_prior_ordinary_income: change_in_prior_ordinary_income,
          change_in_prior_net_income: change_in_prior_net_income,
          owners_equity: owners_equity,
          number_of_shares: number_of_shares,
          number_of_treasury_stock: number_of_treasury_stock,
          net_assets_per_share: net_assets_per_share,
          document_title_cover_page: document_title_cover_page,
          fiscal_year_cover_page: fiscal_year_cover_page,
          current_fiscal_year_end_date: current_fiscal_year_end_date,
          company_name: company_name,
          filing_date: filing_date,
          start_date: start_date,
          end_date: end_date,
          number_of_employees: number_of_employees,
          segments: segments
        }
      end

      def attributes_results_forecast
        {
          code: code,
          year: quarter == 4 ? year + 1 : year,
          month: month,
          quarter: 4,
          consolidation: consolidation,
          forecast_net_sales: forecast_net_sales,
          forecast_operating_income: forecast_operating_income,
          forecast_ordinary_income: forecast_ordinary_income,
          forecast_net_income: forecast_net_income,
          forecast_net_income_per_share: forecast_net_income_per_share,
          change_in_forecast_net_sales: change_in_forecast_net_sales,
          change_in_forecast_operating_income: change_in_forecast_operating_income,
          change_in_forecast_ordinary_income: change_in_forecast_ordinary_income,
          change_in_forecast_net_income: change_in_forecast_net_income,
        }
      end
    end
  end
end
