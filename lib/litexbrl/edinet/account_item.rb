module LiteXBRL
  module Edinet
    module AccountItem

      def self.define_item(items, &block)
        items.map do |item|
          block.call item
        end.flatten
      end

      def self.define_nested_item(nested_items, &block)
        nested_items.map do |items|
          define_item(items, &block)
        end
      end

      # 売上高
      NET_SALES = ['NetSales', 'NetSalesSummaryOfBusinessResults', 'RevenueIFRSSummaryOfBusinessResults']

      # 営業利益
      OPERATING_INCOME = ['OperatingIncome', 'OperatingIncomeIFRSSummaryOfBusinessResults', 'GrossProfit']

      # 経常利益
      ORDINARY_INCOME = ['OrdinaryIncome', 'OrdinaryIncomeLossSummaryOfBusinessResults']

      # 純利益
      NET_INCOME = ['NetIncome', 'NetIncomeLossSummaryOfBusinessResults']

      # 一株当たり純利益
      NET_INCOME_PER_SHARE = ['NetIncomePerShare', 'NetIncomePerShareUS', 'BasicNetIncomePerShareUS',
        'BasicEarningsPerShareIFRS', 'BasicEarningPerShareIFRS']

      # 報告書のタイプ
      DOCUMENT_TITLE_COVER_PAGE = ['DocumentTitleCoverPage']

      # 決算期
      FISCAL_YEAR_COVER_PAGE = ['FiscalYearCoverPage','QuarterlyAccountingPeriodCoverPage']

      # 企業名
      COMPANY_NAME = ['CompanyNameCoverPage']

      # 提出日
      FILING_DATE = ['FilingDateCoverPage']

      # 当事業年度開始日
      CURRENT_FISCAL_YEAR_START_DATE = ['CurrentFiscalYearStartDateDEI']

      # 当事業年度終了日
      CURRENT_FISCAL_YEAR_END_DATE = ['CurrentFiscalYearEndDateDEI']

      # 当会計期間開始日
      CURRENT_PERIOD_START_DATE = ['CurrentPeriodStartDateDEI']

      # 当会計期間終了日
      CURRENT_PERIOD_END_DATE = ['CurrentPeriodEndDateDEI']

      # 当会計期間の種類
      TYPE_OF_CURRENT_PERIOD = ['TypeOfCurrentPeriodDEI']

      # 従業員数
      NUMBER_OF_EMPLOYEES = ['NumberOfEmployees']

      # 単一セグメント
      SINGLE_SEGMENT = ['DescriptionOfFactThatCompanysBusinessComprisesSingleSegment']

      # セグメント毎のcontextRef
      SEGMENT_CONTEXT_REF_NAME = ['']

      # セグメント毎の英名
      SEGMENT_ENGLISH_NAME = ['']

      # セグメント毎の売上高
      SEGMENT_SALES = ['']

      # セグメント毎の営業利益
      SEGMENT_OPERATING_PROFIT = ['']

    end
  end
end
