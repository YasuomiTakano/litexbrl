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
        namespaces = doc.namespaces

        # TODO 委嬢する？
        if security_report? namespaces
          SecurityReport
        # elsif summary2? namespaces
        #   Summary2
        # elsif results_forecast? namespaces
        #   ResultsForecast
        # elsif results_forecast2? namespaces
        #   ResultsForecast2
        else
          raise StandardError.new "ドキュメントがありません"
        end
      end

      def security_report?(namespaces)
        namespaces.keys.any? {|ns| /jpcrp.+(asr|ussm|ifsm)/ =~ ns }
      end

      # def summary2?(namespaces)
      #   namespaces.keys.any? {|ns| /tse-.+(jpsm|ussm|ifsm)/ =~ ns }
      # end

      # def results_forecast?(namespaces)
      #   namespaces.keys.any? {|ns| /edinet-rvfc/ =~ ns }
      # end

      # def results_forecast2?(namespaces)
      #   namespaces.keys.any? {|ns| /tse-rvfc/ =~ ns }
      # end

    end

  end
end
