require 'obo/parser'

module Mspire
  class Obo
    class HeaderParser < ::Obo::Parser
      def initialize
      end

      def header(filename)
        File.open(filename) do |io|
          elements(io).next
        end
      end
    end
  end
end
