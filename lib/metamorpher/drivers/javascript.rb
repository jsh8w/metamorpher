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
        puts ast
        #ast.to_ecma
      end

      def source_location_for(literal)
        ast = ast_for(literal)
        (ast.range.from.index..ast.range.to.index)
      end

      private

      def import(ast)
        create_literal_for(ast)
      end

      def create_literal_for(ast)
        # Get child nodes for node in question
        children = get_child_nodes(ast)

        # if there are no children (i.e we're at a leaf node)
        if children.empty?
          Terms::Literal.new(name: ast.class)
        else # we're at a non-terminal node
          Terms::Literal.new(name: ast.class, children: get_child_nodes(ast).map { |c| import(c) })
        end
      end

      # RKelly returns AST
      # But it doesn't have a method to retrieve children of a node
      # This method returns array of child nodes
      def get_child_nodes(ast)
        # Array to contain nodes 'below' node in question
        all_nodes = Array.new

        # Array to contain child nodes
        child_nodes = Array.new

        # Inspect each node 'below' node in question, add to array
        ast.each do |node|
          all_nodes.push(node)
        end

        # if there is at least 1 node 'below' node in question
        if all_nodes.length > 1
          # Get first grandchild node
          grandchild_node = Array.new
          all_nodes[1].each_with_index do |node, index|
            if index == 1
              grandchild_node.push(node)
            end
          end

          # Loop through all nodes below original node
          all_nodes[1..all_nodes.length].each do |node|
            # if we've reached grandchild level of tree, break
            # else we've found a child, so add to array
            if node == grandchild_node[0]
              break
            else
              child_nodes.push(node)
            end
          end
        end

        child_nodes
      end

      def export(literal)
        if literal.branch?
          RKelly::Nodes::Node.new(literal.name)

        elsif keyword?(literal)
          # Unparser requires leaf nodes containing keywords to be represented as nodes.
          RKelly::Nodes::Node.new(literal.name)

        else
          # Unparser requires all other leaf nodes to be represented as primitives.
          RKelly::Nodes::Node.new(literal.name)
        end

        literal.children.each do |child|
          export(child)
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

javascript = Metamorpher::Drivers::JavaScript.new
ast = javascript.parse('2 + 2;')
#puts ast
code = javascript.unparse(ast)
puts code
