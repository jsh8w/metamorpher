require "metamorpher/drivers/javascript"
require "metamorpher/builders/ast/builder"

module Metamorpher
  module Drivers
    describe JavaScript, focus: true do
      let(:builder) { Builders::AST::Builder.new }

      describe "for a simple program containing a RKelly Node" do
        let(:source)  { "2;" }
        let(:literal) do
          builder.literal!(
            RKelly::Nodes::SourceElementsNode,
            builder.literal!(RKelly::Nodes::ExpressionStatementNode,
                             builder.literal!(RKelly::Nodes::NumberNode, 2))
          )
        end

        it "should parse a simple program to literals" do
          expect(subject.parse(source)).to eq(literal)
        end

        it "should unparse valid literals to source" do
          expect(subject.unparse(literal)).to eq(source)
        end

        it "should provide source location of literals" do
          subject.parse(source)

          expect(subject.source_location_for(literal)).to eq(0..1)
        end
      end

      describe "for a simple program containing a RKelly BinaryNode" do
        let(:source)  { "2 + 1;" }
        let(:literal) do
          builder.literal!(
            RKelly::Nodes::SourceElementsNode,
            builder.literal!(RKelly::Nodes::ExpressionStatementNode,
                             builder.literal!(RKelly::Nodes::AddNode,
                                              builder.literal!(RKelly::Nodes::NumberNode, 2), builder.literal!(RKelly::Nodes::NumberNode, 1)))
          )
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

      describe "for a simple program containing a RKelly BracketAccessorNode, ResolveNode, OpEqualNode" do
        let(:source)  { "y = x[1];" }
        let(:literal) do
          builder.literal!(
            RKelly::Nodes::SourceElementsNode,
            builder.literal!(RKelly::Nodes::ExpressionStatementNode,
                             builder.literal!(RKelly::Nodes::OpEqualNode,
                                              builder.literal!(RKelly::Nodes::ResolveNode, "y"), builder.literal!(RKelly::Nodes::BracketAccessorNode,
                                                                                                                  builder.literal!(RKelly::Nodes::ResolveNode, "x"), builder.literal!(RKelly::Nodes::NumberNode, 1))))
          )
        end

        it "should parse a simple program to literals" do
          expect(subject.parse(source)).to eq(literal)
        end

        it "should unparse valid literals to source" do
          expect(subject.unparse(literal)).to eq(source)
        end
      end

      describe "for a simple program containing a RKelly CaseClauseNode" do
        let(:source)  do
          'switch(x) {
  case 1:
    break;
}'
        end
        let(:literal) do
          builder.literal!(
            RKelly::Nodes::SourceElementsNode,
            builder.literal!(RKelly::Nodes::SwitchNode,
                             builder.literal!(RKelly::Nodes::ResolveNode, 'x'),
                             builder.literal!(RKelly::Nodes::CaseBlockNode,
                                              builder.literal!(RKelly::Nodes::CaseClauseNode,
                                                               builder.literal!(RKelly::Nodes::NumberNode, 1), builder.literal!(RKelly::Nodes::SourceElementsNode, builder.literal!(RKelly::Nodes::BreakNode, nil)))))
          )
        end

        it "should parse a simple program to literals" do
          expect(subject.parse(source)).to eq(literal)
        end

        it "should unparse valid literals to source" do
          expect(subject.unparse(literal)).to eq(source)
        end
      end

      describe "for a simple program containing a RKelly CommaNode" do
        let(:source)  { "a, b;" }
        let(:literal) do
          builder.literal!(
            RKelly::Nodes::SourceElementsNode,
            builder.literal!(RKelly::Nodes::ExpressionStatementNode,
                             builder.literal!(RKelly::Nodes::CommaNode,
                                              builder.literal!(RKelly::Nodes::ResolveNode, 'a'), builder.literal!(RKelly::Nodes::ResolveNode, 'b')))
          )
        end

        it "should parse a simple program to literals" do
          expect(subject.parse(source)).to eq(literal)
        end

        it "should unparse valid literals to source" do
          expect(subject.unparse(literal)).to eq(source)
        end
      end

      describe "for a simple program containing a RKelly ConditionalNode" do
        let(:source)  { "x = (y < 2) ? 1 : 2;" }
        let(:literal) do
          builder.literal!(
            RKelly::Nodes::SourceElementsNode,
            builder.literal!(RKelly::Nodes::ExpressionStatementNode,
                             builder.literal!(RKelly::Nodes::OpEqualNode,
                                              builder.literal!(RKelly::Nodes::ResolveNode, 'x'), builder.literal!(RKelly::Nodes::ConditionalNode,
                                                                                                                  builder.literal!(RKelly::Nodes::ParentheticalNode,
                                                                                                                                   builder.literal!(RKelly::Nodes::LessNode, builder.literal!(RKelly::Nodes::ResolveNode, 'y'), builder.literal!(RKelly::Nodes::NumberNode, 2))),
                                                                                                                  builder.literal!(RKelly::Nodes::NumberNode, 1), builder.literal!(RKelly::Nodes::NumberNode, 2))))
          )
        end

        it "should parse a simple program to literals" do
          expect(subject.parse(source)).to eq(literal)
        end

        it "should unparse valid literals to source" do
          expect(subject.unparse(literal)).to eq(source)
        end
      end

      describe "for a simple program containing a RKelly DotAccessorNode" do
        let(:source)  { "a.name;" }
        let(:literal) do
          builder.literal!(
            RKelly::Nodes::SourceElementsNode,
            builder.literal!(RKelly::Nodes::ExpressionStatementNode,
                             builder.literal!(RKelly::Nodes::DotAccessorNode,
                                              builder.literal!(RKelly::Nodes::ResolveNode, 'a'), builder.literal!('accessor', 'name')))
          )
        end

        it "should parse a simple program to literals" do
          expect(subject.parse(source)).to eq(literal)
        end

        it "should unparse valid literals to source" do
          expect(subject.unparse(literal)).to eq(source)
        end
      end

      describe "for a simple program containing a RKelly ForNode" do
        let(:source)  do
          "for(i = 0; i < 5; i++) {

}"
        end
        let(:literal) do
          builder.literal!(
            RKelly::Nodes::SourceElementsNode,
            builder.literal!(RKelly::Nodes::ForNode,
                             builder.literal!(RKelly::Nodes::OpEqualNode,
                                              builder.literal!(RKelly::Nodes::ResolveNode, 'i'),
                                              builder.literal!(RKelly::Nodes::NumberNode, 0)),
                             builder.literal!(RKelly::Nodes::LessNode,
                                              builder.literal!(RKelly::Nodes::ResolveNode, 'i'),
                                              builder.literal!(RKelly::Nodes::NumberNode, 5)),
                             builder.literal!(RKelly::Nodes::PostfixNode,
                                              builder.literal!(RKelly::Nodes::ResolveNode, 'i'),
                                              builder.literal!('operator', '++')),
                             builder.literal!(RKelly::Nodes::BlockNode,
                                              builder.literal!(RKelly::Nodes::SourceElementsNode, [])))
          )
        end

        it "should parse a simple program to literals" do
          expect(subject.parse(source)).to eq(literal)
        end

        it "should unparse valid literals to source" do
          expect(subject.unparse(literal)).to eq(source)
        end
      end

      describe "for a simple program containing a RKelly ForInNode" do
        let(:source)  do
          "for(x in personArray) {

}"
        end
        let(:literal) do
          builder.literal!(
            RKelly::Nodes::SourceElementsNode,
            builder.literal!(RKelly::Nodes::ForInNode,
                             builder.literal!(RKelly::Nodes::ResolveNode, 'x'),
                             builder.literal!(RKelly::Nodes::ResolveNode, 'personArray'),
                             builder.literal!(RKelly::Nodes::BlockNode, builder.literal!(RKelly::Nodes::SourceElementsNode, [])))
          )
        end

        it "should parse a simple program to literals" do
          expect(subject.parse(source)).to eq(literal)
        end

        it "should unparse valid literals to source" do
          expect(subject.unparse(literal)).to eq(source)
        end
      end

      describe "for a simple program containing a RKelly FunctionCallNode" do
        let(:source)  { "myFunction(x);" }
        let(:literal) do
          builder.literal!(
            RKelly::Nodes::SourceElementsNode,
            builder.literal!(RKelly::Nodes::ExpressionStatementNode,
                             builder.literal!(RKelly::Nodes::FunctionCallNode,
                                              builder.literal!(RKelly::Nodes::ResolveNode, 'myFunction'), builder.literal!(RKelly::Nodes::ArgumentsNode,
                                                                                                                           builder.literal!(RKelly::Nodes::ResolveNode, 'x'))))
          )
        end

        it "should parse a simple program to literals" do
          expect(subject.parse(source)).to eq(literal)
        end

        it "should unparse valid literals to source" do
          expect(subject.unparse(literal)).to eq(source)
        end
      end

      describe "for a simple program containing a RKelly FunctionDeclNode, FunctionExprNode" do
        let(:source)  do
          "function myFunction(x) {

}"
        end
        let(:literal) do
          builder.literal!(
            RKelly::Nodes::SourceElementsNode,
            builder.literal!(RKelly::Nodes::FunctionDeclNode,
                             builder.literal!(RKelly::Nodes::ParameterNode, 'x'), builder.literal!(RKelly::Nodes::FunctionBodyNode,
                                                                                                   builder.literal!(RKelly::Nodes::SourceElementsNode, [])),
                             builder.literal!('name', 'myFunction'))
          )
        end

        it "should parse a simple program to literals" do
          expect(subject.parse(source)).to eq(literal)
        end

        it "should unparse valid literals to source" do
          expect(subject.unparse(literal)).to eq(source)
        end
      end

      describe "for a simple program containing a RKelly FunctionDeclNode with multiple parameters" do
        let(:source)  do
          "function myFunction(x, y) {

}"
        end
        let(:literal) do
          builder.literal!(
            RKelly::Nodes::SourceElementsNode,
            builder.literal!(RKelly::Nodes::FunctionDeclNode,
                             builder.literal!(RKelly::Nodes::ParameterNode, 'x'), builder.literal!(RKelly::Nodes::ParameterNode, 'y'), builder.literal!(RKelly::Nodes::FunctionBodyNode,
                                                                                                                                                        builder.literal!(RKelly::Nodes::SourceElementsNode, [])),
                             builder.literal!('name', 'myFunction'))
          )
        end

        it "should parse a simple program to literals" do
          expect(subject.parse(source)).to eq(literal)
        end

        it "should unparse valid literals to source" do
          expect(subject.unparse(literal)).to eq(source)
        end
      end

      describe "for a simple program containing a RKelly IfNode" do
        let(:source)  { "if(true) 4; else 5;" }
        let(:literal) do
          builder.literal!(
            RKelly::Nodes::SourceElementsNode,
            builder.literal!(RKelly::Nodes::IfNode,
                             builder.literal!(RKelly::Nodes::TrueNode, 'true'), builder.literal!(RKelly::Nodes::ExpressionStatementNode,
                                                                                                 builder.literal!(RKelly::Nodes::NumberNode, 4)),
                             builder.literal!(RKelly::Nodes::ExpressionStatementNode,
                                              builder.literal!(RKelly::Nodes::NumberNode, 5)))
          )
        end

        it "should parse a simple program to literals" do
          expect(subject.parse(source)).to eq(literal)
        end

        it "should unparse valid literals to source" do
          expect(subject.unparse(literal)).to eq(source)
        end
      end

      describe "for a simple program containing a RKelly LabelNode, BlockNode" do
        let(:source)  do
          "Outer: {

}"
        end
        let(:literal) do
          builder.literal!(
            RKelly::Nodes::SourceElementsNode,
            builder.literal!(RKelly::Nodes::LabelNode,
                             builder.literal!(RKelly::Nodes::BlockNode, builder.literal!(RKelly::Nodes::SourceElementsNode, [])),
                             builder.literal!('name', 'Outer'))
          )
        end

        it "should parse a simple program to literals" do
          expect(subject.parse(source)).to eq(literal)
        end

        it "should unparse valid literals to source" do
          expect(subject.unparse(literal)).to eq(source)
        end
      end

      describe "for a simple program containing a RKelly NewExprNode" do
        let(:source)  do
          "arr = new Array();"
        end
        let(:literal) do
          builder.literal!(
            RKelly::Nodes::SourceElementsNode,
            builder.literal!(RKelly::Nodes::ExpressionStatementNode,
                             builder.literal!(RKelly::Nodes::OpEqualNode,
                                              builder.literal!(RKelly::Nodes::ResolveNode, 'arr'), builder.literal!(RKelly::Nodes::NewExprNode,
                                                                                                                    builder.literal!(RKelly::Nodes::ResolveNode, 'Array'), builder.literal!(RKelly::Nodes::ArgumentsNode, []))))
          )
        end

        it "should parse a simple program to literals" do
          expect(subject.parse(source)).to eq(literal)
        end

        it "should unparse valid literals to source" do
          expect(subject.unparse(literal)).to eq(source)
        end
      end

      describe "for a simple program containing a RKelly NotStrictEqualNode" do
        let(:source)  do
          "a !== b;"
        end
        let(:literal) do
          builder.literal!(
            RKelly::Nodes::SourceElementsNode,
            builder.literal!(RKelly::Nodes::ExpressionStatementNode,
                             builder.literal!(RKelly::Nodes::NotStrictEqualNode,
                                              builder.literal!(RKelly::Nodes::ResolveNode, 'a'), builder.literal!(RKelly::Nodes::ResolveNode, 'b')))
          )
        end

        it "should parse a simple program to literals" do
          expect(subject.parse(source)).to eq(literal)
        end

        it "should unparse valid literals to source" do
          expect(subject.unparse(literal)).to eq(source)
        end
      end

      describe "for a simple program containing a RKelly PostfixNode" do
        let(:source)  do
          'i++;'
        end
        let(:literal) do
          builder.literal!(
            RKelly::Nodes::SourceElementsNode,
            builder.literal!(RKelly::Nodes::ExpressionStatementNode,
                             builder.literal!(RKelly::Nodes::PostfixNode, builder.literal!(RKelly::Nodes::ResolveNode, 'i'), builder.literal!('operator', '++')))
          )
        end

        it "should parse a simple program to literals" do
          expect(subject.parse(source)).to eq(literal)
        end

        it "should unparse valid literals to source" do
          expect(subject.unparse(literal)).to eq(source)
        end
      end

      describe "for a simple program containing a RKelly PrefixNode" do
        let(:source)  do
          '++i;'
        end
        let(:literal) do
          builder.literal!(
            RKelly::Nodes::SourceElementsNode,
            builder.literal!(RKelly::Nodes::ExpressionStatementNode,
                             builder.literal!(RKelly::Nodes::PrefixNode, builder.literal!(RKelly::Nodes::ResolveNode, 'i'), builder.literal!('operator', '++')))
          )
        end

        it "should parse a simple program to literals" do
          expect(subject.parse(source)).to eq(literal)
        end

        it "should unparse valid literals to source" do
          expect(subject.unparse(literal)).to eq(source)
        end
      end

      describe "for a simple program containing a RKelly PropertyNode" do
        let(:source)  do
          "person = {
  age: 20
};"
        end
        let(:literal) do
          builder.literal!(
            RKelly::Nodes::SourceElementsNode,
            builder.literal!(RKelly::Nodes::ExpressionStatementNode,
                             builder.literal!(RKelly::Nodes::OpEqualNode,
                                              builder.literal!(RKelly::Nodes::ResolveNode, 'person'), builder.literal!(RKelly::Nodes::ObjectLiteralNode,
                                                                                                                       builder.literal!(RKelly::Nodes::PropertyNode,
                                                                                                                                        builder.literal!(RKelly::Nodes::NumberNode, 20), builder.literal!('name', 'age')))))
          )
        end

        it "should parse a simple program to literals" do
          expect(subject.parse(source)).to eq(literal)
        end

        it "should unparse valid literals to source" do
          expect(subject.unparse(literal)).to eq(source)
        end
      end

      describe "for a simple program containing a RKelly StrictEqualNode" do
        let(:source)  do
          "a === b;"
        end
        let(:literal) do
          builder.literal!(
            RKelly::Nodes::SourceElementsNode,
            builder.literal!(RKelly::Nodes::ExpressionStatementNode,
                             builder.literal!(RKelly::Nodes::StrictEqualNode,
                                              builder.literal!(RKelly::Nodes::ResolveNode, 'a'), builder.literal!(RKelly::Nodes::ResolveNode, 'b')))
          )
        end

        it "should parse a simple program to literals" do
          expect(subject.parse(source)).to eq(literal)
        end

        it "should unparse valid literals to source" do
          expect(subject.unparse(literal)).to eq(source)
        end
      end

      describe "for a simple program containing a RKelly TryNode" do
        let(:source)  do
          "try {

} catch(err) {

}"
        end
        let(:literal) do
          builder.literal!(
            RKelly::Nodes::SourceElementsNode,
            builder.literal!(RKelly::Nodes::TryNode,
                             builder.literal!(RKelly::Nodes::BlockNode,
                                              builder.literal!(RKelly::Nodes::SourceElementsNode, [])),
                             builder.literal!(RKelly::Nodes::BlockNode,
                                              builder.literal!(RKelly::Nodes::SourceElementsNode, [])),
                             builder.literal!('catch_var', 'err'))
          )
        end

        it "should parse a simple program to literals" do
          expect(subject.parse(source)).to eq(literal)
        end

        it "should unparse valid literals to source" do
          expect(subject.unparse(literal)).to eq(source)
        end
      end

      describe "for a simple program containing a RKelly VarDeclNode" do
        let(:source) { "var x = 1;" }
        let(:literal) do
          builder.literal!(
            RKelly::Nodes::SourceElementsNode,
            builder.literal!(RKelly::Nodes::VarStatementNode,
                             builder.literal!(RKelly::Nodes::VarDeclNode,
                                              builder.literal!(RKelly::Nodes::AssignExprNode, builder.literal!(RKelly::Nodes::NumberNode, 1)),
                                              builder.literal!('name', 'x'),
                                              builder.literal!('constant', false)))
          )
        end

        it "should parse a simple program to literals" do
          expect(subject.parse(source)).to eq(literal)
        end

        it "should unparse valid literals to source" do
          expect(subject.unparse(literal)).to eq(source)
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
