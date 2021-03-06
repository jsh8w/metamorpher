require "metamorpher"
require "metamorpher/builders/ast"

describe "Matching" do
  let(:builder) { Metamorpher::Builders::AST::Builder.new }

  describe "literals" do
    class SuccZeroMatcher
      include Metamorpher::Matcher
      include Metamorpher::Builders::AST

      def pattern
        builder.succ(0)
      end
    end

    subject { SuccZeroMatcher.new }

    it "should return a match for a matching expression" do
      expression = builder.succ(0)

      expect(subject.run(expression)).to have_matched(expression)
    end

    it "should return no match for a non-matching expression" do
      expression = builder.succ(1)

      expect(subject.run(expression)).not_to have_matched
    end
  end

  describe "variables" do
    class SuccMatcher
      include Metamorpher::Matcher
      include Metamorpher::Builders::AST

      def pattern
        builder.succ(builder.X)
      end
    end

    subject { SuccMatcher.new }

    it "should return a match for matching expressions" do
      expressions = [
        builder.succ(0),
        builder.succ(1),
        builder.succ(:n),
        builder.succ(builder.succ(:n))
      ]

      expressions.each do |expression|
        expect(subject.run(expression)).to have_matched(expression)
      end
    end

    it "should return no match for a non-matching expression" do
      expression = builder.pred(1)

      expect(subject.run(expression)).not_to have_matched
    end
  end

  describe "conditional variables" do
    class DynamicFinderMatcher
      include Metamorpher::Matcher
      include Metamorpher::Builders::AST

      def pattern
        builder.literal!(
          :".",
          :User,
          builder.METHOD { |literal| literal.name =~ /^find_by_/ }
        )
      end
    end

    subject { DynamicFinderMatcher.new }

    it "should return a match for matching expression" do
      expression = builder.literal!(:".", :User, :find_by_name)

      expect(subject.run(expression)).to have_matched(expression)
    end

    it "should return no match when the condition is not satisfied" do
      expression = builder.literal!(:".", :User, :find)

      expect(subject.run(expression)).not_to have_matched
    end
  end

  describe "greedy variables" do
    class MultiAddMatcher
      include Metamorpher::Matcher
      include Metamorpher::Builders::AST

      def pattern
        builder.add(
          builder.ARGS_
        )
      end
    end

    subject { MultiAddMatcher.new }

    it "should return a match for matching expressions" do
      expressions = [
        builder.add(1),
        builder.add(1, 2),
        builder.add(1, 2, 3),
        builder.add(1, builder.succ(:n), 2)
      ]

      expressions.each do |expression|
        expect(subject.run(expression)).to have_matched(expression)
      end
    end

    it "should return no match when there are no arguments" do
      expression = builder.add

      expect(subject.run(expression)).not_to have_matched
    end

    it "should return no match when names do not match" do
      expression = builder.multiply(1, 2, 3)

      expect(subject.run(expression)).not_to have_matched
    end
  end

  describe "alternatives" do
    class CalculatorOperatorMatcher
      include Metamorpher::Matcher
      include Metamorpher::Builders::AST

      def pattern
        builder.either!(
          builder.add(builder.ARGS_),
          builder.subtract(builder.ARGS_),
          builder.clear
        )
      end
    end

    subject { CalculatorOperatorMatcher.new }

    it "should return a match for matching add expressions" do
      expressions = [
        builder.add(1),
        builder.add(1, 2),
        builder.add(1, 2, 3),
        builder.add(1, builder.succ(:n), 2)
      ]

      expressions.each do |expression|
        expect(subject.run(expression)).to have_matched(expression)
      end
    end

    it "should return a match for matching subtract expressions" do
      expressions = [
        builder.subtract(1),
        builder.subtract(1, 2),
        builder.subtract(1, 2, 3),
        builder.subtract(1, builder.succ(:n), 2)
      ]

      expressions.each do |expression|
        expect(subject.run(expression)).to have_matched(expression)
      end
    end

    it "should return a match for matching clear expression" do
      expect(subject.run(builder.clear)).to have_matched(builder.clear)
    end

    it "should return no match for near misses" do
      expressions = [
        builder.add,
        builder.subtract,
        builder.empty,
        builder.multiply(1, 2, 3)
      ]

      expressions.each do |expression|
        expect(subject.run(expression)).not_to have_matched(expression)
      end
    end
  end
end
