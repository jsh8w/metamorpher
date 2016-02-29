require "metamorpher/builders/ast"

module Metamorpher
  module Builders
    module JavaScript
      class ASTSimplifier
        def simplify(ast)
          export(ast)
        end

        private

        def export(literal)
          # if literal is not a container node OR
          # literal is a container node but it's child's children is a leaf node e.g NumberNode OR
          # literal is a LogicalNot, UnaryMinus, BitwiseNot or UnaryPlus.
          # These nodes are exceptions
          if literal.children.length != 1 ||
             (literal.children.length == 1 && literal.children.first.children.length == 0) ||
             literal.name.to_s.include?("LogicalNot") ||
             literal.name.to_s.include?("UnaryMinus") ||
             literal.name.to_s.include?("BitwiseNot") ||
             literal.name.to_s.include?("UnaryPlus")
            # Create literal
            Terms::Literal.new(name: literal.name, children: literal.children.map { |c| export(c) })
          else
            # Move onto child node
            export(literal.children.first)
          end
        end
      end
    end
  end
end
