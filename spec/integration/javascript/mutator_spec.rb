require "metamorpher"
require "tempfile"

describe "Mutator" do
  describe "for JavaScript", focus: true do
    module JavaScript
      class LessThanMutator
        include Metamorpher::Mutator
        include Metamorpher::Builders::JavaScript

        def pattern
          builder.build_pattern("A < B")
        end

        def replacement
          builder.build("A > B", "A == B", "A != B")
        end
      end
    end

    subject { JavaScript::LessThanMutator.new }

    let(:mutatable) do
      "if(4 < 5) 4; else 5;"
    end

    let(:mutated) do
      [
        "if(4 > 5) 4; else 5;",
        "if(4 == 5) 4; else 5;",
        "if(4 != 5) 4; else 5;"
      ]
    end

    let(:not_mutatable) { "foo == bar" }

    describe "by calling mutate" do
      describe "for code that can be mutated" do
        it "should return the mutated code" do
          expect(subject.mutate(mutatable)).to eq(mutated)
        end

        it "should yield for each mutation site" do
          expect { |b| subject.mutate(mutatable, &b) }.to yield_successive_args(
            site_for(3..7, "4 < 5", "4 > 5"),
            site_for(3..7, "4 < 5", "4 == 5"),
            site_for(3..7, "4 < 5", "4 != 5")
          )
        end
      end

      describe "for code that cannot be mutated" do
        it "should return no mutants" do
          expect(subject.mutate(not_mutatable)).to eq([])
        end

        it "should not yield when there are no mutants" do
          expect { |b| subject.mutate(not_mutatable, &b) }.not_to yield_control
        end
      end
    end

    describe "mutate_file" do
      describe "for code that can be mutated" do
        let(:mutatable_file) { create_temporary_javascript_file("mutatable", mutatable) }

        it "should return the mutated code" do
          expect(subject.mutate_file(mutatable_file)).to eq(mutated)
        end

        it "should yield for each mutating site" do
          expect { |b| subject.mutate_file(mutatable_file, &b) }.to yield_successive_args(
            site_for(3..7, "4 < 5", "4 > 5"),
            site_for(3..7, "4 < 5", "4 == 5"),
            site_for(3..7, "4 < 5", "4 != 5")
          )
        end
      end

      describe "for code that cannot be mutated" do
        let(:not_mutatable_file) do
          create_temporary_javascript_file("not_mutatable", not_mutatable)
        end

        it "should return no mutants" do
          expect(subject.mutate_file(not_mutatable_file)).to eq([])
        end

        it "should not yield when there are no mutating site" do
          expect { |b| subject.mutate_file(not_mutatable_file, &b) }.not_to yield_control
        end
      end
    end

    describe "mutate_files" do
      let(:mutatable_file) { create_temporary_javascript_file("mutatable", mutatable) }
      let(:clone_of_mutatable_file) { create_temporary_javascript_file("mutatable", mutatable) }

      let(:different_mutating_sites_file) do
        create_temporary_javascript_file(
          "differently_mutatable",
          "result = foo < bar"
        )
      end

      let(:not_mutatable_file) do
        create_temporary_javascript_file(
          "not_mutatable",
          "nothing_to_see_here = 42"
        )
      end

      let(:files) do
        [
          mutatable_file,
          clone_of_mutatable_file,
          different_mutating_sites_file,
          not_mutatable_file
        ]
      end

      it "should return a map of the paths and mutated code" do
        mutated_files = {
          mutatable_file => mutated,
          clone_of_mutatable_file => mutated,
          different_mutating_sites_file => ["result = foo > bar", "result = foo == bar", "result = foo != bar"],
          not_mutatable_file => []
        }

        expect(subject.mutate_files(files)).to eq(mutated_files)
      end

      it "should yield for each file" do
        mutatable_file_details = [
          mutatable_file,
          mutated,
          [
            site_for(3..7, "4 < 5", "4 > 5"),
            site_for(3..7, "4 < 5", "4 == 5"),
            site_for(3..7, "4 < 5", "4 != 5")
          ]
        ]

        clone_of_mutatable_file_details = [
          clone_of_mutatable_file,
          mutated,
          [
            site_for(3..7, "4 < 5", "4 > 5"),
            site_for(3..7, "4 < 5", "4 == 5"),
            site_for(3..7, "4 < 5", "4 != 5")
          ]
        ]

        different_mutating_sites_file_details = [
          different_mutating_sites_file,
          ["result = foo > bar", "result = foo == bar", "result = foo != bar"],
          [
            site_for(9..17, "foo < bar", "foo > bar"),
            site_for(9..17, "foo < bar", "foo == bar"),
            site_for(9..17, "foo < bar", "foo != bar")
          ]
        ]

        not_mutatable_file_details = [
          not_mutatable_file,
          [],
          []
        ]

        summary = []
        subject.mutate_files(files) { |*args| summary << args }

        expect(summary[0]).to eq(mutatable_file_details)
        expect(summary[1]).to eq(clone_of_mutatable_file_details)
        expect(summary[2]).to eq(different_mutating_sites_file_details)
        expect(summary[3]).to eq(not_mutatable_file_details)
      end
    end

    def site_for(original_position, original_code, mutated_code)
      Metamorpher::Transformer::Site.new(
        original_position,
        original_code,
        mutated_code
      )
    end

    def create_temporary_javascript_file(filename, contents)
      Tempfile.new([filename, ".js"]).tap do |tempfile|
        tempfile.write(contents)
        tempfile.close
      end.path
    end
  end
end
