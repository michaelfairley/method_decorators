require 'spec_helper'
require 'method_decorators/memoize'

describe MethodDecorators::Memoize do
  describe "#call" do
    let(:method) { double(:method, :call => :calculation) }
    let(:this) { Object.new }
    subject { MethodDecorators::Memoize.new }

    it "calculates the value the first time the arguments are supplied" do
      method.should_receive(:call)
      subject.call(method, this, 10)
    end

    it "stores the value of the method call" do
      method.stub(:call).and_return(:foo, :bar)
      subject.call(method, this, 10).should == :foo
      subject.call(method, this, 10).should == :foo
    end

    it "memoizes the return value and skips the call the second time" do
      subject.call(method, this, 10)
      method.should_not_receive(:call)
      subject.call(method, this, 10)
    end

    it "memoizes different values for different arguments" do
      method.stub(:call).with(10).and_return(:foo, :bar)
      method.stub(:call).with(20).and_return(:bar, :foo)
      subject.call(method, this, 10).should == :foo
      subject.call(method, this, 10).should == :foo
      subject.call(method, this, 20).should == :bar
      subject.call(method, this, 20).should == :bar
    end
  end

  describe "acceptance" do
    let(:klass) do
      Class.new Base do
        +MethodDecorators::Memoize
        def count
          @count ||= 0
          @count += 1
          rand
        end

        +MethodDecorators::Memoize
        def zero
          0
        end

        +MethodDecorators::Memoize
        def one
          1
        end
      end
    end
    subject { klass.new }

    it "memoizes calls to the method" do
      x = subject.count
      subject.count.should == x
      #subject.count.should == 1
      #subject.count.should == 1
    end

    it "memoizes call to different methods separately" do
      subject.zero.should eql 0
      subject.one.should eql 1
    end

    context "with two instances of the decorated class" do
      let(:o1) { subject }
      let(:o2) { klass.new }
      it "cache does not interact with that of other instances" do
        o1.count.should_not == o2.count
      end
    end
  end
end
