require 'spec_helper'
require 'method_decorators/decorators/retry'

describe Retry do
  let(:method) { double(:method, :call => false) }
  subject { Retry.new(3) }

  describe "#call" do
    it "executes the method again if the first time failed " do
      method.stub(:call){ raise }

      method.should_receive(:call).exactly(3).times
      expect{ subject.call(method, nil) }.to raise_error
    end

    it "does not retry the method if it succeeds" do
      method.should_receive(:call).once.and_return(3)
      subject.call(method, nil).should == 3
    end
  end

  describe "acceptance" do
    let(:klass) do
      Class.new Base do
        +Retry.new(3)
        def do_it(magic_number)
          @times ||= 0
          @times += 1
          raise  if @times == magic_number
          @times
        end
      end
    end
    subject { klass.new }

    it "memoizes calls to the method" do
      subject.do_it(1).should == 2
    end
  end
end
