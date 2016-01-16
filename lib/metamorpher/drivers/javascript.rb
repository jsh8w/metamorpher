require "metamorpher/drivers/parse_error"
require "metamorpher/terms/literal"
require "rkelly"

module Metamorpher
  module Drivers
    class JavaScript
      def parse(src)
        import(@root = parser.parse(src))
      rescue RKelly::SyntaxError
        raise ParseError
      end

      private

      def import(ast)
        create_literal_for(ast)
      end

      def create_literal_for(ast)
        puts ast
        if ast.respond_to? :type
          Terms::Literal.new(name: ast.type, children: ast.children.map { |c| import(c) })
        else
          Terms::Literal.new(name: ast)
        end
      end

      def parser
        @parser ||= RKelly::Parser.new
      end
    end
  end
end

# javascript = Metamorpher::Drivers::JavaScript.new
# ast = javascript.parse('2 + 2')
