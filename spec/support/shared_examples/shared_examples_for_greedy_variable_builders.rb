require "metamorpher/terms/variable"

module Metamorpher
  module Terms
    shared_examples "a greedy variable builder" do
      describe "greedy_variable!" do
        it "should create an instance of Variable with greedy? set to true" do
          actual = subject.greedy_variable!(:a)
          expected = Variable.new(name: :a, greedy?: true)

          expect(actual).to eq(expected)
        end

        it "should create condition from block" do
          built = subject.greedy_variable!(:a) { |term| term > 0 }

          expect(built.name).to eq(:a)
          expect(built.condition.call(1)).to be_truthy
          expect(built.condition.call(-1)).to be_falsey
        end

        it "should not allow children" do
          expect { subject.greedy_variable!(:a, 1) }.to raise_error(ArgumentError)
        end
      end

      describe "greedy variable shorthand" do
        it "should create an instance of Variable with greedy? set to true" do
          actual = subject.A_
          expected = Variable.new(name: :a, greedy?: true)

          expect(actual).to eq(expected)
        end

        it "should create condition from block" do
          built = subject.A_ { |term| term > 0 }

          expect(built.name).to eq(:a)
          expect(built.condition.call(1)).to be_truthy
          expect(built.condition.call(-1)).to be_falsey
        end

        it "should not allow children" do
          expect { subject.A_(1) }.to raise_error(ArgumentError)
        end
      end
    end
  end
end
