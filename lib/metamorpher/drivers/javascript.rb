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
        ast.to_ecma
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
        # if ast is an RKelly node. i.e not an attribute of a node
        if ast.is_a?(RKelly::Nodes::Node)
          # Get child nodes for node in question
          children = get_child_nodes(ast)

          # Check if this node has any 'attributes'
          # Returned as e.g [[attribute_name, attribute_value]]
          attributes = get_node_attribute_names(ast)
          children = children + attributes

          # if there are no children (i.e we're at a leaf node)
          if children.empty?
            # Add primitive node after this leaf RKelly node
            # e.g if AST leaf node is NumberNode, add '2' as a node as child
            Terms::Literal.new(name: ast.class, children: [Terms::Literal.new(name: ast.value)])
          else # we're at a non-terminal node
            Terms::Literal.new(name: ast.class, children: children.map { |c| import(c) })
          end
        else
          # Create Metamorpher literal with attribute name -> attribute value
          # e.g where ast = VarDeclNode, name -> x, and constant = false
          Terms::Literal.new(name: ast[0], children: [Terms::Literal.new(name: ast[1])])
        end
      end

      # RKelly returns AST
      # But it doesn't have a method to retrieve children of a node
      # This method returns array of child nodes
      def get_child_nodes(ast)
        # Array to contain nodes 'below' node in question
        all_nodes = []

        # Array to contain child nodes
        child_nodes = []

        # Inspect each node 'below' node in question, add to array
        ast.each do |node|
          all_nodes.push(node)
        end

        # if there is at least 1 node 'below' node in question
        if all_nodes.length > 1
          # Get first grandchild node
          grandchild_node = []
          all_nodes[1].each_with_index do |node, index|
            grandchild_node.push(node) if index == 1
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

      def get_node_attribute_names(ast)
        # Attributes array to return
        attributes = []

        # if node is a BinaryNode, it has a 'left' and 'right'
        # These are both children so exception to the standard of 'value'
        # Being the only child
        if ast.is_a?(RKelly::Nodes::BinaryNode)
          attributes
        else
          # Get the nodes constructor parameters
          # This is an array of arrays e.g [[req, name], [req, value]]
          node_parameters = ast.class.instance_method(:initialize).parameters

          # Loop through parameters
          node_parameters.each do |parameter|
            # Get the parameter name
            attribute_name = parameter[1].to_s
            # if the parameter is not 'value', i.e not the nodes child
            if attribute_name != 'value'
              # Get the parameter value
              attribute_value = ast.instance_variable_get("@#{attribute_name}")
              attributes.push([attribute_name, attribute_value])
            end
          end
          attributes
        end
      end

      def export(literal)
        # if node is not a primitive
        if literal.name.to_s.include? "RKelly::Nodes::"
          # Get name of RKelly node stored in literal e.g SourceElementsNode
          node_name = literal.name.to_s.split('RKelly::Nodes::', 2)[1]

          # Create full RKelly node name e.g RKelly::Nodes::SourceElementsNode
          rkelly_node_name = "RKelly::Nodes::#{node_name}"

          # if node has > 1 children
          if literal.children.length > 1
            # Get constructor paramters of the node we're creating
            node_object = Object::const_get(rkelly_node_name)
            node_parameters = node_object.instance_method(:initialize).parameters
            parameters = []

            node_parameters.each do |parameter|
              attribute_name = parameter[1].to_s
              parameters.push(attribute_name)
            end
            ##----------------

            # Create array of arguments in same order as parameters
            # Match a nodes attributes onto parameters
            arguments = []
            child_nodes = []
            literal.children.each do |node|
              match = false
              parameters.each_with_index do |parameter, index|
                if parameter == node.name.to_s
                  arguments[index] = node.children[0].name.to_s
                  match = true
                end
              end
              if match == false
                child_nodes.push(node)
              end
            end

            # Add actual RKelly child nodes at first free element in array
            child_nodes.each do |node|
              arguments.each_with_index do |argument, index|
                if argument.nil?
                  arguments[index] = child_nodes.shift
                end
              end
            end

            # If nodes have not yet been matched, add onto the end of array
            child_nodes.each do |node|
              arguments.push(node)
            end
            ##----------------

            if rkelly_node_name == "RKelly::Nodes::VarDeclNode"
              node = eval(rkelly_node_name).new(literal.children[1].children[0].name.to_s, export(literal.children.first), literal.children[2].children[0].name.to_s)
            elsif rkelly_node_name == "RKelly::Nodes::AddNode"
              node = eval(rkelly_node_name).new(export(literal.children.first), export(literal.children.last))
            end
          else
            # Node has a single child. e,g SourceElementsNode etc
            # if child node is not a leaf node
            if literal.children.first.name.to_s.include? "RKelly::Nodes::"
              # Nodes that require array as argument
              array_nodes = ["Arguments", "Array", "CaseBlock", "ConstStatement", "ObjectLiteral", "SourceElements", "VarStatement"]
              # if node requires array as argument
              if array_nodes.any? { |node| rkelly_node_name.include?(node) }
                node = eval(rkelly_node_name).new([export(literal.children.first)])
              else
                node = eval(rkelly_node_name).new(export(literal.children.first))
              end
            else
              # child node is a primitive. e.g '2'
              node = eval(rkelly_node_name).new(literal.children.first.name)
            end
          end
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
ast = javascript.parse('var x = 2 + 2;')
# puts ast
code = javascript.unparse(ast)
puts code
