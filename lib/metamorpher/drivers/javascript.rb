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

      def unparse(literal)
        ast = export(literal)
        ast.to_ecma()
      end

      def source_location_for(literal)
        ast = ast_for(literal)
        (ast.loc.expression.begin_pos..(ast.loc.expression.end_pos - 1))
      end

      private

      def import(ast)
        create_literal_for(ast)
      end

      def create_literal_for(ast)
        if ast.respond_to? :type
          Terms::Literal.new(name: ast.type, children: ast.children.map { |c| import(c) })
        else
          Terms::Literal.new(name: ast)
        end
      end

      def export(literal)
        if literal.branch?
          RKelly::Node.new(literal.name, literal.children.map { |c| export(c) })

        elsif keyword?(literal)
          # RKelly requires leaf nodes containing keywords to be represented as nodes.
          RKelly::Node.new(literal.name)

        else
          # RKelly requires all other leaf nodes to be represented as primitives.
          literal.name
        end
      end

      def keyword?(literal)
        literal.leaf? && !literal.child_of?(:sym) && keywords.include?(literal.name)
      end

      def keywords
        # The symbols used by RKelly for JavaScript keywords. The current implementation
        # is not a definitive list. If unparsing fails, it might be due to this list
        # omitting a necessary keyword. Note that these are the symbols produced
        # by Parser which are not necessarily the same as JavaScript keywords (e.g.,
        # Parser sometimes produces a :zsuper node for a program of the form "super")
        @keywords ||= %i(nil false true self)
      end

      def ast_for(literal)
        literal.path.reduce(@root) { |a, e| a.children[e] }
      end

      def parser
        @parser ||= RKelly::Parser.new
      end
    end
  end
end

# javascript = Metamorpher::Drivers::JavaScript.new
# ast = javascript.parse('var x = 2 + 2;')
# puts ast
# code = javascript.unparse(ast)
# puts code
