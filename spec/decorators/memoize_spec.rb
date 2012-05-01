require 'spec_helper'
require 'method_decorators/decorators/memoize'

describe Memoize do
  let(:method) { mock(:method, call: :calculation) }
  subject { Memoize.new }

  describe "memoization" do
    it "calculates the value the first time the arguments are supplied" do
      method.should_receive(:call)
      subject.call(method, 10)
    end

    it "stores the value of the method call" do
      method.stub(:call).and_return(:foo, :bar)
      subject.call(method, 10).should eq :foo
      subject.call(method, 10).should eq :foo
    end

    it "memoizes the return value and skips the call the second time" do
      subject.call(method, 10)
      method.should_not_receive(:call)
      subject.call(method, 10)
    end
  end
end
