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
        ast.to_ecma.to_s
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
          children += attributes

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
        all_nodes.shift

        # While there are still nodes to inspect
        until all_nodes.empty?
          # First element of array is a child
          child_nodes.push(all_nodes[0])

          # Get all children below the child
          grandchild_nodes = []
          all_nodes[0].each do |grandchild|
            grandchild_nodes.push(grandchild)
          end
          #---------------

          # Remove grandchildren from nodes to inspect
          all_nodes -= grandchild_nodes
        end

        child_nodes
      end

      def get_node_attribute_names(ast)
        # Attributes array to return
        attributes = []

        # If we've got a node with multiple children
        # e.g BinaryNode, it has a 'left' and 'right'
        # Nodes with no extra attributes not represented as nodes
        if ast.is_a?(RKelly::Nodes::BinaryNode) ||
           ast.is_a?(RKelly::Nodes::OpEqualNode) ||
           ast.is_a?(RKelly::Nodes::IfNode) ||
           ast.is_a?(RKelly::Nodes::ForNode) || ast.is_a?(RKelly::Nodes::ForInNode) || ast.is_a?(RKelly::Nodes::CommaNode) ||
           ast.is_a?(RKelly::Nodes::BracketAccessorNode) ||
           ast.is_a?(RKelly::Nodes::FunctionCallNode) ||
           ast.is_a?(RKelly::Nodes::NewExprNode)
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
            if attribute_name != 'value' &&
               !ast.is_a?(RKelly::Nodes::PostfixNode) &&
               !ast.is_a?(RKelly::Nodes::TryNode) &&
               !ast.is_a?(RKelly::Nodes::DotAccessorNode) &&
               !ast.is_a?(RKelly::Nodes::FunctionExprNode)
              # Get the parameter value
              attribute_value = ast.instance_variable_get("@#{attribute_name}")
              attributes.push([attribute_name, attribute_value])
            elsif attribute_name != 'operand' && ast.is_a?(RKelly::Nodes::PostfixNode)
              # PostFixNode is different to all other nodes
              # it inherits 'value' from Node however it's not a child node
              # parameter 'operator' -> super(operator) i.e value
              attribute_value = ast.instance_variable_get("@value")
              attributes.push([attribute_name, attribute_value])
            elsif attribute_name != 'value' &&
                  attribute_name != 'catch_block' &&
                  attribute_name != 'finally_block' &&
                  ast.is_a?(RKelly::Nodes::TryNode)
              # TryNode is different to all other nodes
              # 'value' is a child node 'try_block'
              # 'catch_block' is a child node 'catch_block'
              # 'finally_block' is a child node 'finally_block'
              attribute_value = ast.instance_variable_get("@#{attribute_name}")
              # finally_block is optional so need to check if nil
              unless attribute_value.nil?
                attributes.push([attribute_name, attribute_value])
              end
            elsif attribute_name != 'resolve' && ast.is_a?(RKelly::Nodes::DotAccessorNode)
              # DotAccessorNode only has resolve as a child
              # Need to get the 'accessor'
              attribute_value = ast.instance_variable_get("@#{attribute_name}")
              attributes.push([attribute_name, attribute_value])
            elsif attribute_name == 'name' && ast.is_a?(RKelly::Nodes::FunctionExprNode)
              # FunctionExprNode has 'function_body' and 'arguments' as children
              # Need to get the 'name' which is it's 'value'
              attribute_value = ast.instance_variable_get("@value")
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

          # Nodes that require array as argument
          array_nodes = %w(Arguments Array CaseBlock ConstStatement ObjectLiteral SourceElements VarStatement)

          # if node has > 1 children
          if literal.children.length > 1
            # Get constructor parameters of the node we're creating
            parameters = get_rkelly_node_parameters(rkelly_node_name)

            # Create array of arguments in same order as parameters
            arguments = construct_rkelly_node_arguments(literal, parameters)

            # if node requires array as argument
            if array_nodes.any? { |node| rkelly_node_name.include?(node) }
              node = eval(rkelly_node_name).new([*arguments])
            else
              node = eval(rkelly_node_name).new(*arguments)
            end

          else
            # Node has a single child. e,g SourceElementsNode etc
            # if child node is not a leaf node
            if literal.children.first.name.to_s.include? "RKelly::Nodes::"
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

      def get_rkelly_node_parameters(rkelly_node_name)
        node_object = Object.const_get(rkelly_node_name)
        node_parameters = node_object.instance_method(:initialize).parameters
        parameters = []

        node_parameters.each do |parameter|
          attribute_name = parameter[1].to_s
          parameters.push(attribute_name)
        end

        parameters
      end

      def construct_rkelly_node_arguments(literal, parameters)
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
          child_nodes.push(node) if match == false
        end

        # A FunctionDecl(Expr)Node requires 'parameter' children to be combined into an array
        # This block reconstructs the child_nodes array
        # By constructing an argument array and adding to to the child_nodes array
        if literal.name.to_s.include?("RKelly::Nodes::FunctionDeclNode") ||
           literal.name.to_s.include?("RKelly::Nodes::FunctionExprNode")
          function_arguments = []
          child_nodes.delete_if do |node|
            if node.name.to_s.include?("RKelly::Nodes::ParameterNode")
              function_arguments.push(node)
              true
            end
          end
          child_nodes.push(function_arguments)
        end

        # Add actual RKelly child nodes at first free element in array
        child_nodes.each do |node|
          arguments.each_with_index do |argument, index|
            if argument.nil?
              # Check if we've got Parameters array for FunctionDeclNode
              # Then export each parameter and add array to arguments
              if node.is_a?(Array)
                params = []
                node.each do |parameter_node|
                  params.push(export(parameter_node))
                end
                arguments[index] = params
                child_nodes.shift
              else
                arguments[index] = export(child_nodes.shift)
              end
            end
          end
        end

        # If nodes have not yet been matched, add onto the end of array
        child_nodes.each do |node|
          # Check if we've got Parameters array for FunctionDeclNode
          # Then export each parameter and add array to arguments
          if node.is_a?(Array)
            params = []
            node.each do |parameter_node|
              params.push(export(parameter_node))
            end
            arguments.push(params)
          else
            arguments.push(export(node))
          end
        end
        ##----------------

        arguments
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
        literal.path.reduce(@root) do |a, e|
          children = get_child_nodes(a)
          children[e]
        end
      end

      def parser
        @parser ||= RKelly::Parser.new
      end
    end
  end
end
