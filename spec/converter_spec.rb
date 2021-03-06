require 'spec_helper'

describe GFM::Converter do
  before { @converter = GFM::Converter.new('tmp/README.md') }

  describe "creating an instance without a proper file" do
    it "throws and error if the file is not a markdown file" do
      expect { GFM::Converter.new("blah blah not a markdown file") }.to raise_error
    end

    it "throws and error if the file does not exist" do
      expect { GFM::Converter.new("non_existent_file.md") }.to raise_error
    end
  end

  describe "#input_file_name" do
    it "sets the correct input file name" do
      @converter.input_file_name.should == 'tmp/README.md'
    end
  end

  describe "#output_file_name" do
    it "is nil until written" do
      @converter.output_file_name.should be_nil
    end
  end

  describe "#write_output_file" do
    context "with no filename given" do
      before { @converter.write_output_file }

      it "sets the output file name" do
        @converter.output_file_name.should == 'tmp/README.html'
      end

      it "creates the file" do
        File.exists?('tmp/README.html').should == true
      end

      it "only replaces .md" do
        converter = GFM::Converter.new("tmp/mdmd.md")
        converter.write_output_file
        converter.output_file_name.should == "tmp/mdmd.html"
      end
    end

    context "with a filename given" do
      context "with no html extension given" do
        before { @converter.write_output_file('tmp/output') }

        it "sets the output file name" do
          @converter.output_file_name.should == 'tmp/output.html'
        end

        it "writes the file" do
          File.exists?('tmp/output.html').should == true
        end
      end

      context "with an html extension given" do
        before { @converter.write_output_file('tmp/output.html') }

        it "sets the correct filename" do
          @converter.output_file_name.should == 'tmp/output.html'
        end
      end
    end
  end
end
