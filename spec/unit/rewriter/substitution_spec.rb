require "metamorpher/terms/variable"
require "metamorpher/terms/derived"
require "metamorpher/terms/literal"

module Metamorpher
  module Terms
    describe Variable do
      subject { Variable.new(name: :type) }

      it "should return the element of the substitution with the correct name" do
        substitution = { type: Literal.new(name: :sub) }
        expect(subject.substitute(substitution)).to eq(substitution[:type])
      end

      it "should raise if the substitution contains no value for variable's name" do
        expect { subject.substitute({}) }.to raise_error(Rewriter::SubstitutionError)
      end
    end

    describe Derived do
      subject do
        Derived.new(
          base: [:type],
          derivation: -> (type) { Literal.new(name: type.name.reverse) }
        )
      end

      it "should return the element of the substitution after calling derivation" do
        substitution = { type: Literal.new(name: "reverse_me") }

        expect(subject.substitute(substitution)).to eq(
          Literal.new(name: "reverse_me".reverse)
        )
      end

      it "should raise if the substitution contains no value for variable's name" do
        expect { subject.substitute({}) }.to raise_error(Rewriter::SubstitutionError)
      end

      context "default derivations" do
        it "should be the identity function for a single parameter" do
          subject = Derived.new(base: [:type])
          literal = Literal.new(name: :foo)
          substitution = { type: literal }

          expect(subject.substitute(substitution)).to eq(literal)
        end
      end
    end

    describe Literal do
      describe "with no children" do
        subject { Literal.new(name: :root) }

        it "should return the original literal" do
          expect(subject.substitute({})).to eq(subject)
        end
      end

      describe "with children" do
        subject do
          Literal.new(
            name: :root,
            children: [
              Literal.new(name: :child, children: [Variable.new(name: :foo)])
            ]
          )
        end

        let(:child) { literal.children.first }
        let(:grandchild) { child.children.first }

        it "should return the original literal with substituted descendants" do
          substitution = { foo: Literal.new(name: :bar) }

          expect(subject.substitute(substitution)).to eq(
            Literal.new(
              name: :root,
              children: [
                Literal.new(
                  name: :child,
                  children: [Literal.new(name: :bar)]
                )
              ]
            )
          )
        end

        it "should contain all elements if the substituted value is an array" do
          substitution = { foo: [Literal.new(name: :bar), Literal.new(name: :baz)] }

          expect(subject.substitute(substitution)).to eq(
            Literal.new(
              name: :root,
              children: [
                Literal.new(
                  name: :child,
                  children: [Literal.new(name: :bar), Literal.new(name: :baz)]
                )
              ]
            )
          )
        end
      end
    end

    describe TermSet do
      let(:first_child) { Variable.new(name: :type) }

      let(:second_child) do
        Derived.new(
          base: [:type],
          derivation: -> (type) { Literal.new(name: type.name.reverse) }
        )
      end

      subject { TermSet.new(terms: [first_child, second_child]) }

      it "should perform substitution on each child" do
        substitution = { type: Literal.new(name: "sub") }
        expected = TermSet.new(terms: [Literal.new(name: "sub"), Literal.new(name: "sub".reverse)])

        expect(subject.substitute(substitution)).to eq(expected)
      end
    end
  end
end
