require "metamorpher"

describe Metamorpher do
  subject { Metamorpher.builder }
  before { Metamorpher.configure(builder: :javascript) }

  let(:ast_builder) { Metamorpher::Builders::AST::Builder.new }

  describe "when building literals" do
    it "should produce literals from source" do
      expect(subject.build("1 + 1")).to eq(
        ast_builder.literal!(RKelly::Nodes::AddNode, ast_builder.literal!(RKelly::Nodes::NumberNode, 1), ast_builder.literal!(RKelly::Nodes::NumberNode, 1))
      )
    end

    it "should raise for invalid source" do
      silence_stream(STDERR) do
        expect { subject.build("1 + ") }.to raise_error(Metamorpher::Drivers::ParseError)
      end
    end
  end

  describe "when building patterns" do
    it "should introduce TermSets into the AST" do
      actual = subject.build_pattern("A < B")

      a_termset = ast_builder.either!(
        ast_builder.literal!(RKelly::Nodes::BreakNode, ast_builder.A),
        ast_builder.literal!(RKelly::Nodes::ContinueNode, ast_builder.A),
        ast_builder.literal!(RKelly::Nodes::EmptyStatementNode, ast_builder.A),
        ast_builder.literal!(RKelly::Nodes::FalseNode, ast_builder.A),
        ast_builder.literal!(RKelly::Nodes::NullNode, ast_builder.A),
        ast_builder.literal!(RKelly::Nodes::NumberNode, ast_builder.A),
        ast_builder.literal!(RKelly::Nodes::ParameterNode, ast_builder.A),
        ast_builder.literal!(RKelly::Nodes::RegexpNode, ast_builder.A),
        ast_builder.literal!(RKelly::Nodes::ResolveNode, ast_builder.A),
        ast_builder.literal!(RKelly::Nodes::StringNode, ast_builder.A),
        ast_builder.literal!(RKelly::Nodes::ThisNode, ast_builder.A),
        ast_builder.literal!(RKelly::Nodes::TrueNode, ast_builder.A)
      )

      b_termset = ast_builder.either!(
        ast_builder.literal!(RKelly::Nodes::BreakNode, ast_builder.B),
        ast_builder.literal!(RKelly::Nodes::ContinueNode, ast_builder.B),
        ast_builder.literal!(RKelly::Nodes::EmptyStatementNode, ast_builder.B),
        ast_builder.literal!(RKelly::Nodes::FalseNode, ast_builder.B),
        ast_builder.literal!(RKelly::Nodes::NullNode, ast_builder.B),
        ast_builder.literal!(RKelly::Nodes::NumberNode, ast_builder.B),
        ast_builder.literal!(RKelly::Nodes::ParameterNode, ast_builder.B),
        ast_builder.literal!(RKelly::Nodes::RegexpNode, ast_builder.B),
        ast_builder.literal!(RKelly::Nodes::ResolveNode, ast_builder.B),
        ast_builder.literal!(RKelly::Nodes::StringNode, ast_builder.B),
        ast_builder.literal!(RKelly::Nodes::ThisNode, ast_builder.B),
        ast_builder.literal!(RKelly::Nodes::TrueNode, ast_builder.B)
      )

      expected = ast_builder.literal!(RKelly::Nodes::LessNode, a_termset, b_termset)

      expect(actual).to eq(expected)
    end
  end

  describe "when building programs containing constants" do
    it "should convert uppercase constants to variables" do
      expect(subject.build("LEFT + RIGHT")).to eq(
        ast_builder.literal!(RKelly::Nodes::AddNode, ast_builder.literal!(RKelly::Nodes::ResolveNode, ast_builder.LEFT), ast_builder.literal!(RKelly::Nodes::ResolveNode, ast_builder.RIGHT))
      )
    end

    it "should convert uppercase messages to variables" do
      expect(subject.build("User.METHOD")).to eq(
        ast_builder.literal!(RKelly::Nodes::DotAccessorNode, ast_builder.literal!(RKelly::Nodes::ResolveNode, ast_builder.literal!('User')), ast_builder.literal!('accessor', ast_builder.METHOD))
      )
    end

    it "should convert uppercase constants ending with underscore to greedy variables" do
      expect(subject.build("LEFT_ + RIGHT_")).to eq(
        ast_builder.literal!(RKelly::Nodes::AddNode, ast_builder.literal!(RKelly::Nodes::ResolveNode, ast_builder.LEFT_), ast_builder.literal!(RKelly::Nodes::ResolveNode, ast_builder.RIGHT_))
      )
    end

    it "should not convert non-uppercase constants to variables" do
      expect(subject.build("Left + RIGHt")).to eq(
        ast_builder.literal!(RKelly::Nodes::AddNode, ast_builder.literal!(RKelly::Nodes::ResolveNode, ast_builder.literal!('Left')), ast_builder.literal!(RKelly::Nodes::ResolveNode, ast_builder.literal!('RIGHt')))
      )
    end
  end

  describe "when building programs with conditional variables" do
    it "should create a conditional variable from a call to ensuring" do
      built = subject.build("A").ensuring("A") { |n| n > 0 }

      first_variable = built.children.first

      expect(first_variable.name).to eq(:a)
      expect(first_variable.condition.call(1)).to be_truthy
      expect(first_variable.condition.call(-1)).to be_falsey
    end

    it "should create several conditional variables from several calls to ensuring" do
      built = subject
              .build("A + B")
              .ensuring("A") { |n| n > 0 }
              .ensuring("B") { |n| n < 0 }

      first_variable = built.children.first.children.first
      last_variable = built.children.last.children.last

      expect(first_variable.name).to eq(:a)
      expect(first_variable.condition.call(1)).to be_truthy
      expect(first_variable.condition.call(-1)).to be_falsey

      expect(last_variable.name).to eq(:b)
      expect(last_variable.condition.call(-1)).to be_truthy
      expect(last_variable.condition.call(1)).to be_falsey
    end
  end

  describe "when building programs with derivations" do
    it "should create a derivation from a call to deriving" do
      built = subject.build("PLURAL").deriving("PLURAL", "SINGULAR") do |constant|
        subject.build(constant.children.first.name.to_s + "s")
      end

      first_variable = built.children.first

      expect(first_variable.base).to eq([:singular])
      expect(first_variable.derivation.call(subject.build("dog"))).to eq(subject.build("dogs"))
    end

    it "should create a derivation with multiple bases from a call to deriving" do
      built = subject.build("HASH").deriving("HASH", "KEY", "VALUE") {}

      first_variable = built.children.first

      expect(first_variable.base).to eq([:key, :value])
    end

    it "should create several derivations from several calls to deriving" do
      built = subject
              .build("NEW_FIRST; NEW_LAST")
              .deriving("NEW_FIRST", "FIRST") {}
              .deriving("NEW_LAST", "LAST") {}

      first_derived = built.children.first.children.first
      last_derived = built.children.last.children.last

      expect(first_derived.base).to eq([:first])
      expect(last_derived.base).to eq([:last])
    end
  end

  describe "when building with alternatives" do
    it "should produce a termset" do
      actual = subject.build("1 + 1", "LEFT + RIGHT")

      expected_literals = ast_builder.literal!(RKelly::Nodes::AddNode, ast_builder.literal!(RKelly::Nodes::NumberNode, 1), ast_builder.literal!(RKelly::Nodes::NumberNode, 1))

      expected_variables = ast_builder.literal!(RKelly::Nodes::AddNode, ast_builder.literal!(RKelly::Nodes::ResolveNode, ast_builder.LEFT), ast_builder.literal!(RKelly::Nodes::ResolveNode, ast_builder.RIGHT))

      expected = ast_builder.either!(expected_literals, expected_variables)

      expect(actual).to eq(expected)
    end

    it "should raise for invalid source" do
      silence_stream(STDERR) do
        expect { subject.build("1 + ") }.to raise_error(Metamorpher::Drivers::ParseError)
      end
    end
  end
end
