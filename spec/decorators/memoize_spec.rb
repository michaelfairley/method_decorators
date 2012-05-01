require 'spec_helper'
require 'method_decorators/decorators/memoize'

describe Memoize do
  describe "#call" do
    let(:method) { double(:method, :call => :calculation) }
    subject { Memoize.new }

    it "calculates the value the first time the arguments are supplied" do
      method.should_receive(:call)
      subject.call(method, 10)
    end

    it "stores the value of the method call" do
      method.stub(:call).and_return(:foo, :bar)
      subject.call(method, 10).should == :foo
      subject.call(method, 10).should == :foo
    end

    it "memoizes the return value and skips the call the second time" do
      subject.call(method, 10)
      method.should_not_receive(:call)
      subject.call(method, 10)
    end

    it "memoizes different values for different arguments" do
      method.stub(:call).with(10).and_return(:foo, :bar)
      method.stub(:call).with(20).and_return(:bar, :foo)
      subject.call(method, 10).should == :foo
      subject.call(method, 10).should == :foo
      subject.call(method, 20).should == :bar
      subject.call(method, 20).should == :bar
    end
  end

  describe "acceptance" do
    let(:klass) do
      Class.new Base do
        +Memoize
        def count
          @count ||= 0
          @count += 1
        end
      end
    end
    subject { klass.new }

    it "memoizes calls to the method" do
      subject.count.should == 1
      subject.count.should == 1
    end
  end
end
