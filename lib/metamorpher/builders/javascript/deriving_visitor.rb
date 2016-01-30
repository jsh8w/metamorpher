require "metamorpher/builders/javascript/variable_replacement_visitor"

module Metamorpher
  module Builders
    module JavaScript
      class DerivingVisitor < VariableReplacementVisitor
        def initialize(variable_name, *base, derivation)
          super(variable_name, Terms::Derived.new(base: base, derivation: derivation))
        end
      end
    end
  end
end
