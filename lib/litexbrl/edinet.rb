require 'litexbrl/edinet/account_item'
require 'litexbrl/edinet/security_report_attribute'
require 'litexbrl/edinet/company_attribute'
require 'litexbrl/edinet/financial_information'
require 'litexbrl/edinet/security_report'
require 'litexbrl/edinet/financial_information2'

module LiteXBRL
  module Edinet

    class << self

      def parse(path)
        doc = File.open(path) {|f| Nokogiri::XML f }
        read doc
      end

      def parse_string(str)
        doc = Nokogiri::XML str
        read doc
      end

      private

      def read(doc)
        document = find_document doc

        document.read doc
      end

      def find_document(doc)
        SecurityReport
      end
    end

  end
end
