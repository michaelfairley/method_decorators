require 'spec_helper'
require 'method_decorators/precondition'

describe MethodDecorators::Precondition do
  let(:receiver) { double(:receiver) }
  let(:method) { double(:method, :call => :secret, :receiver => receiver) }
  let(:block) { proc { |arg| true } }
  subject { MethodDecorators::Precondition.new(&block) }

  describe "#call" do
    it "raises when the precondition fails" do
      subject.stub(:passes?){ false }
      expect{ subject.call(method, nil) }.to raise_error(ArgumentError)
    end

    it "executes the method when authorization succeeds" do
      subject.stub(:passes?){ true }
      subject.call(method, nil).should == :secret
    end
  end

  describe "acceptance" do
    let(:klass) do
      Class.new Base do
        def initialize(x)
          @x = x
        end

        +MethodDecorators::Precondition.new{ |a| a + @x < 10 }
        def multiply(a)
          a * @x
        end

        +MethodDecorators::Precondition.new{ |a| a + @x == 10 }
        +MethodDecorators::Precondition.new{ |a| a * @x == 21 }
        def concat(a)
          "#{@x}#{a}"
        end
      end
    end
    subject { klass.new(3) }

    context "with one precondition" do
      it "calls the method if the precondition passes" do
        subject.multiply(2).should == 6
      end

      it "raises if the precondition fails" do
        expect{ subject.multiply(8) }.to raise_error(ArgumentError)
      end
    end

    context "with multiple preconditions" do
      it "calls the method if the precondition passes" do
        subject.concat(7).should == "37"
      end

      it "raises if the precondition fails" do
        expect{ subject.concat(8) }.to raise_error(ArgumentError)
      end
    end
  end
end
