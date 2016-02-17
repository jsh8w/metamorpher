require "metamorpher/drivers/javascript"
require "metamorpher/terms/term_set"
require "metamorpher/builders/javascript/term"
require "metamorpher/builders/javascript/uppercase_constant_rewriter"
require "metamorpher/builders/javascript/uppercase_rewriter"
require "metamorpher/builders/javascript/ast_simplifier"

module Metamorpher
  module Builders
    module JavaScript
      class Builder
        def build(*sources)
          terms = sources.map { |source| decorate(rewrite(simplify(parse(source)))) }
          terms.size == 1 ? terms.first : Metamorpher::Terms::TermSet.new(terms: terms)
        end

        private

        def decorate(term)
          term.extend(Term)
        end

        def rewrite(parsed)
          rewriters.reduce(parsed) { |a, e| e.reduce(a) }
        end

        # Method to remove container nodes of JavaScript Metamorpher AST.
        # e.g Nodes that have a single child node
        def simplify(parsed)
          simplifier.simplify(parsed)
        end

        def parse(source)
          term = driver.parse(source)
        end

        def simplifier
          @simplifier ||= ASTSimplifier.new
        end

        def rewriters
          @rewriters ||= [UppercaseConstantRewriter.new, UppercaseRewriter.new]
        end

        def driver
          @driver ||= Drivers::JavaScript.new
        end
      end
    end
  end
end
