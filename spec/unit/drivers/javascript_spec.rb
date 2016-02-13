require "metamorpher/drivers/javascript"
require "metamorpher/builders/ast/builder"

module Metamorpher
  module Drivers
    describe JavaScript do
      let(:builder) { Builders::AST::Builder.new }

      describe "for a simple program" do
        let(:source)  { "2 + 1;" }
        let(:literal) do
          builder.literal!(RKelly::Nodes::SourceElementsNode,
                           builder.literal!(RKelly::Nodes::ExpressionStatementNode, builder.literal!(RKelly::Nodes::AddNode,
                                                                                                     builder.literal!(RKelly::Nodes::NumberNode, 2), builder.literal!(RKelly::Nodes::NumberNode, 1))))
        end

        it "should parse a simple program to literals" do
          expect(subject.parse(source)).to eq(literal)
        end

        it "should unparse valid literals to source" do
          expect(subject.unparse(literal)).to eq(source)
        end

        it "should provide source location of literals" do
          subject.parse(source)

          expect(subject.source_location_for(literal)).to eq(0..5)
        end
      end

      describe "for program that parses to an AST containing nils" do
        let(:source)  { "LEFT + RIGHT;" }
        let(:literal) do
          builder.literal!(RKelly::Nodes::SourceElementsNode,
                           builder.literal!(RKelly::Nodes::ExpressionStatementNode, builder.literal!(RKelly::Nodes::AddNode,
                                                                                                     builder.literal!(RKelly::Nodes::ResolveNode, "LEFT"), builder.literal!(RKelly::Nodes::ResolveNode, "RIGHT"))))
        end

        it "should parse a simple program to literals" do
          expect(subject.parse(source)).to eq(literal)
        end

        it "should unparse valid literals to source" do
          expect(subject.unparse(literal)).to eq(source)
        end
      end

      %w(null true false).each do |keyword|
        describe "for a program containing the '#{keyword}' keyword" do
          let(:source)  { "a = #{keyword};" }
          let(:keyword_node_name) { "RKelly::Nodes::#{keyword.slice(0, 1).capitalize}#{keyword.slice(1..-1)}Node" }
          let(:literal) do
            builder.literal!(RKelly::Nodes::SourceElementsNode,
                             builder.literal!(RKelly::Nodes::ExpressionStatementNode, builder.literal!(RKelly::Nodes::OpEqualNode,
                                                                                                       builder.literal!(RKelly::Nodes::ResolveNode, "a"), builder.literal!(eval(keyword_node_name), keyword))))
          end

          it "should parse to the correct literal" do
            expect(subject.parse(source)).to eq(literal)
          end

          it "should unparse to the correct source" do
            expect(subject.unparse(literal)).to eq(source)
          end
        end

        describe "for a program that is the '#{keyword}' keyword" do
          let(:source)  { "#{keyword};" }
          let(:keyword_node_name) { "RKelly::Nodes::#{keyword.slice(0, 1).capitalize}#{keyword.slice(1..-1)}Node" }
          let(:literal) do
            builder.literal!(RKelly::Nodes::SourceElementsNode,
                             builder.literal!(RKelly::Nodes::ExpressionStatementNode, builder.literal!(eval(keyword_node_name), keyword)))
          end

          it "should parse to the correct literal" do
            expect(subject.parse(source)).to eq(literal)
          end

          it "should unparse to the correct source" do
            expect(subject.unparse(literal)).to eq(source)
          end
        end
      end
    end
  end
end
