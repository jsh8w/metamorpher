require "metamorpher"
require "metamorpher/builders/javascript"

describe "Mutator" do
  describe "for JavaScript", focus: true do
    describe "for Arithmetic Operator Replacement" do
      module JavaScript
        class ArithmeticOperatorReplacement
          include Metamorpher::Mutator
          include Metamorpher::Builders::JavaScript

          def pattern
            builder.build_pattern("A + B")
          end

          def replacement
            builder.build("A - B", "A * B", "A / B", "A % B")
          end
        end
      end

      subject { JavaScript::ArithmeticOperatorReplacement.new }

      let(:mutatable) do
        "var x = 2 + 2;"
      end

      let(:mutated) do
        [
          "var x = 2 - 2;",
          "var x = 2 * 2;",
          "var x = 2 / 2;",
          "var x = 2 % 2;"
        ]
      end

      describe "by calling mutate" do
        describe "for code that can be mutated" do
          it "should return the mutated code" do
            expect(subject.mutate(mutatable)).to eq(mutated)
          end
        end
      end
    end

    describe "for Unary Arithmetic Operator Replacement" do
      module JavaScript
        class UnaryArithmeticOperatorReplacement
          include Metamorpher::Mutator
          include Metamorpher::Builders::JavaScript

          def pattern
            builder.build_pattern("+A")
          end

          def replacement
            builder.build("-A")
          end
        end
      end

      subject { JavaScript::UnaryArithmeticOperatorReplacement.new }

      let(:mutatable) do
        "var x = +1;"
      end

      let(:mutated) do
        [
          "var x = -1;"
        ]
      end

      describe "by calling mutate" do
        describe "for code that can be mutated" do
          it "should return the mutated code" do
            expect(subject.mutate(mutatable)).to eq(mutated)
          end
        end
      end
    end

    describe "for Unary Arithmetic Operator Deletion" do
      module JavaScript
        class UnaryArithmeticOperatorDeletion
          include Metamorpher::Mutator
          include Metamorpher::Builders::JavaScript

          def pattern
            builder.build_pattern("-A")
          end

          def replacement
            builder.build("A")
          end
        end
      end

      subject { JavaScript::UnaryArithmeticOperatorDeletion.new }

      let(:mutatable) do
        "var x = -1;"
      end

      let(:mutated) do
        [
          "var x = 1;"
        ]
      end

      describe "by calling mutate" do
        describe "for code that can be mutated" do
          it "should return the mutated code" do
            expect(subject.mutate(mutatable)).to eq(mutated)
          end
        end
      end
    end

    describe "for Unary Arithmetic Operator Insertion" do
      module JavaScript
        class UnaryArithmeticOperatorInsertion
          include Metamorpher::Mutator
          include Metamorpher::Builders::JavaScript

          def pattern
            builder.build_pattern("A")
          end

          def replacement
            builder.build("-A")
          end
        end
      end

      subject { JavaScript::UnaryArithmeticOperatorInsertion.new }

      let(:mutatable) do
        "var x = 1;"
      end

      let(:mutated) do
        [
          "var x = -1;"
        ]
      end

      describe "by calling mutate" do
        describe "for code that can be mutated" do
          it "should return the mutated code" do
            expect(subject.mutate(mutatable)).to eq(mutated)
          end
        end
      end
    end

    describe "for Short-cut Arithmetic Operator Replacement" do
      module JavaScript
        class ShortcutArithmeticOperatorReplacement
          include Metamorpher::Mutator
          include Metamorpher::Builders::JavaScript

          def pattern
            builder.build_pattern("A++")
          end

          def replacement
            builder.build("A--")
          end
        end
      end

      subject { JavaScript::ShortcutArithmeticOperatorReplacement.new }

      let(:mutatable) do
        "var x = i++;"
      end

      let(:mutated) do
        [
          "var x = i--"
        ]
      end

      describe "by calling mutate" do
        describe "for code that can be mutated" do
          it "should return the mutated code" do
            expect(subject.mutate(mutatable)).to eq(mutated)
          end
        end
      end
    end

    describe "for Short-cut Arithmetic Operator Insertion" do
      module JavaScript
        class ShortcutArithmeticOperatorInsertion
          include Metamorpher::Mutator
          include Metamorpher::Builders::JavaScript

          def pattern
            builder.build_pattern("A")
          end

          def replacement
            builder.build("A++")
          end
        end
      end

      subject { JavaScript::ShortcutArithmeticOperatorInsertion.new }

      let(:mutatable) do
        "var x = y;"
      end

      let(:mutated) do
        [
          "var x = y++;"
        ]
      end

      describe "by calling mutate" do
        describe "for code that can be mutated" do
          it "should return the mutated code" do
            expect(subject.mutate(mutatable)).to eq(mutated)
          end
        end
      end
    end

    describe "for Short-cut Arithmetic Operator Deletion" do
      module JavaScript
        class ShortcutArithmeticOperatorDeletion
          include Metamorpher::Mutator
          include Metamorpher::Builders::JavaScript

          def pattern
            builder.build_pattern("A++")
          end

          def replacement
            builder.build("A")
          end
        end
      end

      subject { JavaScript::ShortcutArithmeticOperatorDeletion.new }

      let(:mutatable) do
        "var x = y++;"
      end

      let(:mutated) do
        [
          "var x = y;"
        ]
      end

      describe "by calling mutate" do
        describe "for code that can be mutated" do
          it "should return the mutated code" do
            expect(subject.mutate(mutatable)).to eq(mutated)
          end
        end
      end
    end

    describe "for Relational Expression Replacement" do
      module JavaScript
        class RelationExpressionReplacement
          include Metamorpher::Mutator
          include Metamorpher::Builders::JavaScript

          def pattern
            builder.build_pattern("A < B")
          end

          def replacement
            builder.build("true", "false")
          end
        end
      end

      subject { JavaScript::RelationExpressionReplacement.new }

      let(:mutatable) do
        "if(4 < 5) 4; else 5;"
      end

      let(:mutated) do
        [
          "if(true) 4; else 5;",
          "if(false) 4; else 5;"
        ]
      end

      describe "by calling mutate" do
        describe "for code that can be mutated" do
          it "should return the mutated code" do
            expect(subject.mutate(mutatable)).to eq(mutated)
          end
        end
      end
    end

    describe "for Relational Operator Replacement" do
      module JavaScript
        class RelationOperatorReplacement
          include Metamorpher::Mutator
          include Metamorpher::Builders::JavaScript

          def pattern
            builder.build_pattern("A < B")
          end

          def replacement
            builder.build("A <= B", "A == B", "A != B", "A >= B", "A > B")
          end
        end
      end

      subject { JavaScript::RelationOperatorReplacement.new }

      let(:mutatable) do
        "if(4 < 5) 4; else 5;"
      end

      let(:mutated) do
        [
          "if(4 <= 5) 4; else 5;",
          "if(4 == 5) 4; else 5;",
          "if(4 != 5) 4; else 5;",
          "if(4 >= 5) 4; else 5;",
          "if(4 > 5) 4; else 5;"
        ]
      end

      describe "by calling mutate" do
        describe "for code that can be mutated" do
          it "should return the mutated code" do
            expect(subject.mutate(mutatable)).to eq(mutated)
          end
        end
      end
    end

    describe "for Conditional Operator Deletion" do
      module JavaScript
        class ConditionalOperatorDeletion
          include Metamorpher::Mutator
          include Metamorpher::Builders::JavaScript

          def pattern
            builder.build_pattern("!A")
          end

          def replacement
            builder.build("A")
          end
        end
      end

      subject { JavaScript::ConditionalOperatorDeletion.new }

      let(:mutatable) do
        "var a = !b;"
      end

      let(:mutated) do
        [
          "var a = b;"
        ]
      end

      describe "by calling mutate" do
        describe "for code that can be mutated" do
          it "should return the mutated code" do
            expect(subject.mutate(mutatable)).to eq(mutated)
          end
        end
      end
    end

    describe "for Conditional Operator Insertion" do
      module JavaScript
        class ConditionalOperatorInsertion
          include Metamorpher::Mutator
          include Metamorpher::Builders::JavaScript

          def pattern
            builder.build_pattern("A")
          end

          def replacement
            builder.build("!A")
          end
        end
      end

      subject { JavaScript::ConditionalOperatorInsertion.new }

      let(:mutatable) do
        "var a = b;"
      end

      let(:mutated) do
        [
          "var a = !b;"
        ]
      end

      describe "by calling mutate" do
        describe "for code that can be mutated" do
          it "should return the mutated code" do
            expect(subject.mutate(mutatable)).to eq(mutated)
          end
        end
      end
    end

    describe "for Conditional Operator Replacement" do
      module JavaScript
        class ConditionalOperatorReplacement
          include Metamorpher::Mutator
          include Metamorpher::Builders::JavaScript

          def pattern
            builder.build_pattern("A || B")
          end

          def replacement
            builder.build("A && B")
          end
        end
      end

      subject { JavaScript::ConditionalOperatorReplacement.new }

      let(:mutatable) do
        "if(x || y) 4; else 5;"
      end

      let(:mutated) do
        [
          "if(x && y) 4; else 5;"
        ]
      end

      describe "by calling mutate" do
        describe "for code that can be mutated" do
          it "should return the mutated code" do
            expect(subject.mutate(mutatable)).to eq(mutated)
          end
        end
      end
    end

    describe "for Shift Operator Replacement" do
      module JavaScript
        class ShiftOperatorReplacement
          include Metamorpher::Mutator
          include Metamorpher::Builders::JavaScript

          def pattern
            builder.build_pattern("A >> B")
          end

          def replacement
            builder.build("A << B", "A >>> B")
          end
        end
      end

      subject { JavaScript::ShiftOperatorReplacement.new }

      let(:mutatable) do
        "x >> y"
      end

      let(:mutated) do
        [
          "x << y",
          "x >>> y"
        ]
      end

      describe "by calling mutate" do
        describe "for code that can be mutated" do
          it "should return the mutated code" do
            expect(subject.mutate(mutatable)).to eq(mutated)
          end
        end
      end
    end

    describe "for Logical Operator Deletion" do
      module JavaScript
        class LogicalOperatorDeletion
          include Metamorpher::Mutator
          include Metamorpher::Builders::JavaScript

          def pattern
            builder.build_pattern("~A")
          end

          def replacement
            builder.build("A")
          end
        end
      end

      subject { JavaScript::LogicalOperatorDeletion.new }

      let(:mutatable) do
        "var x = ~b;"
      end

      let(:mutated) do
        [
          "var x = b;"
        ]
      end

      describe "by calling mutate" do
        describe "for code that can be mutated" do
          it "should return the mutated code" do
            expect(subject.mutate(mutatable)).to eq(mutated)
          end
        end
      end
    end

    describe "for Logical Operator Insertion" do
      module JavaScript
        class LogicalOperatorInsertion
          include Metamorpher::Mutator
          include Metamorpher::Builders::JavaScript

          def pattern
            builder.build_pattern("A")
          end

          def replacement
            builder.build("~A")
          end
        end
      end

      subject { JavaScript::LogicalOperatorInsertion.new }

      let(:mutatable) do
        "var x = b;"
      end

      let(:mutated) do
        [
          "var x = ~b;"
        ]
      end

      describe "by calling mutate" do
        describe "for code that can be mutated" do
          it "should return the mutated code" do
            expect(subject.mutate(mutatable)).to eq(mutated)
          end
        end
      end
    end

    describe "for Logical Operator Replacement" do
      module JavaScript
        class LogicalOperatorReplacement
          include Metamorpher::Mutator
          include Metamorpher::Builders::JavaScript

          def pattern
            builder.build_pattern("A & B")
          end

          def replacement
            builder.build("A | B", "A ^ B")
          end
        end
      end

      subject { JavaScript::LogicalOperatorReplacement.new }

      let(:mutatable) do
        "var x = 5 & 1;"
      end

      let(:mutated) do
        [
          "var x = 5 | 1;",
          "var x = 5 ^ 1;"
        ]
      end

      describe "by calling mutate" do
        describe "for code that can be mutated" do
          it "should return the mutated code" do
            expect(subject.mutate(mutatable)).to eq(mutated)
          end
        end
      end
    end

    describe "for Shortcut Assignment Operator Replacement" do
      module JavaScript
        class ShortcutAssignmentOperatorReplacement
          include Metamorpher::Mutator
          include Metamorpher::Builders::JavaScript

          def pattern
            builder.build_pattern("A += B")
          end

          def replacement
            builder.build("A -= B", "A *= B", "A /= B", "A %= B", "A &= B", "A |= B", "A ^= B", "A <<= B", "A >>= B")
          end
        end
      end

      subject { JavaScript::ShortcutAssignmentOperatorReplacement.new }

      let(:mutatable) do
        "x += 1;"
      end

      let(:mutated) do
        [
          "x -= 1;",
          "x *= 1;",
          "x /= 1;",
          "x %= 1;",
          "x &= 1;",
          "x |= 1;",
          "x ^= 1;",
          "x <<= 1;",
          "x >>= 1;"
        ]
      end

      describe "by calling mutate" do
        describe "for code that can be mutated" do
          it "should return the mutated code" do
            expect(subject.mutate(mutatable)).to eq(mutated)
          end
        end
      end
    end
  end
end
