require "attributable"
require "metamorpher/rewriter/traverser"

module Metamorpher
  module Rewriter
    class Rule
      extend Attributable
      attributes :pattern, :replacement, traverser: Traverser.new

      def apply(ast, &block)
        rewrite_all(ast, matches_for(ast).take(1), &block)
      end

      def reduce(ast, &block)
        rewrite_all(ast, matches_for(ast), &block)
      end

      private

      def rewrite_all(ast, matches, &block)
        matches.reduce(ast) { |a, e| rewrite(a, e, &block) }
      end

      def rewrite(ast, match, &block)
        original = match.root
        substitution = substitution_with_special_values(match)
        rewritten = replacement.substitute(substitution)
        block.call(original, rewritten) if block
        ast.replace(original.path, rewritten)
      end

      def substitution_with_special_values(match)
        match.substitution.dup.tap do |substitution|
          substitution[:&] = match.root.dup # add the "whole match" special variable (&)
        end
      end

      def matches_for(ast)
        traverser.traverse(ast)
          .lazy # only compute the next match when needed
          .map { |current| pattern.match(current) }
          .select(&:matches?)
      end
    end
  end
end
