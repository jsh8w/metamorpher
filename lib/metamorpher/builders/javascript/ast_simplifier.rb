require "metamorpher/builders/ast"
require "metamorpher/builders/javascript/term"
require "metamorpher/builders/javascript/uppercase_constant_rewriter"
require "metamorpher/builders/javascript/uppercase_rewriter"

module Metamorpher
  module Builders
    module JavaScript
      class ASTSimplifier
        def simplify(ast, is_pattern)
          # if we're building a pattern, TermSets are required
          if is_pattern == true
            export_with_termsets(export(ast))
          else
            export(ast)
          end
        end

        private

        def export(literal)
          # if literal is not a container node OR
          # literal is a container node but it's child's children is a leaf node e.g NumberNode
          if literal.children.length != 1 || (literal.children.length == 1 && literal.children.first.children.length == 0)
            # Create literal
            Terms::Literal.new(name: literal.name, children: literal.children.map { |c| export(c) })
          else
            # Move onto child node
            export(literal.children.first)
          end
        end

        # Method to introduce TermSets into pattern ASTs
        # Required because JavaScript AST leaf node's parents can be different types
        # e.g 'A' could be ResolveNode -> A or NumberNode -> A etc
        # TermSet constructed for all possibilities
        def export_with_termsets(literal)
          # if literal is a parent of a child node
          if literal.children.length == 1 && literal.children.first.children.length == 0
            # Build TermSet
            build_termset(literal)
          else
            # Create literal
            Terms::Literal.new(name: literal.name, children: literal.children.map { |c| export_with_termsets(c) })
          end
        end

        def build_termset(literal)
          # Array to hold all possible terms
          terms = []

          # Loop through each potential parent of leaf node and create term
          leaf_node_parents.each do |node|
            # Compute Literal name
            node_name = "RKelly::Nodes::#{node}Node"

            # Construct Leaf node
            # We need to convert to Variable etc before it's added to TermSet
            leaf = decorate(rewrite(Terms::Literal.new(name: literal.children.first.name)))

            # Construct the term and add to array
            term = Terms::Literal.new(name: eval(node_name), children: [leaf])
            terms.push(term)
          end

          # Create and return TermSet
          Terms::TermSet.new(terms: terms)
        end

        def leaf_node_parents
          [
            'Break', 'Continue', 'EmptyStatement', 'False', 'Null', 'Number',
            'Parameter', 'Regexp', 'Resolve', 'String', 'This', 'True'
          ]
        end

        def decorate(term)
          term.extend(Term)
        end

        def rewrite(parsed)
          rewriters.reduce(parsed) { |a, e| e.reduce(a) }
        end

        def rewriters
          @rewriters ||= [UppercaseConstantRewriter.new, UppercaseRewriter.new]
        end
      end
    end
  end
end
