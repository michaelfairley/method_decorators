require 'spec_helper'
require 'method_decorators/decorators/authorize'

describe Authorize do
  let(:receiver) { mock(:receiver) }
  let(:method) { mock(:method, call: :secret, receiver: receiver) }
  let(:block) { proc { |arg| true } }
  subject { Authorize.with(&block) }

  describe ".with" do
    it "creates a new instance of the decorator with the block stored" do
      subject.should be_a_kind_of(Authorize)
      subject.auth.should eq block
    end
  end

  describe "authorization" do
    it "returns false when authorization fails" do
      subject.stub(:authorized?).and_return(false)
      subject.call(method).should be_false
    end

    it "executes the method when authorization succeeds" do
      subject.stub(:authorized?).and_return(true)
      subject.call(method).should eq :secret
    end
  end

  describe "#authorized?" do
    it "passes the method arguments to the authorization method" do
      receiver.should_receive(:instance_exec).with(:foo, &block)
      subject.call(method, :foo)

      receiver.should_receive(:instance_exec).with(:foo, :bar, :baz, &block)
      subject.call(method, :foo, :bar, :baz)
    end
  end
end
