require "metamorpher/builders/javascript/builder"

module Metamorpher
  module Builders
    module JavaScript
      def builder
        @builder ||= Builder.new
      end
    end
  end
end
