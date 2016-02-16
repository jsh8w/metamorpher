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
          # if literal is not a container node
          if literal.children.length != 1
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
