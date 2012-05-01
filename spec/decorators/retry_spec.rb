require 'spec_helper'
require 'method_decorators/decorators/retry'

describe Retry do
  let(:options) { { tries: 2 } }
  let(:method) { mock(:method, call: false) }
  subject { Retry.new(options) }

  describe "default options" do
    subject { Retry.new }
    specify { subject.tries.should eq 2   }
    specify { subject.delay.should eq 1   }
    specify { subject.backoff.should eq 1 }
  end

  describe "#call" do
    before(:each) do
      subject.stub(:wait).and_return(1)
    end

    it "executes the method again if the first time failed " do
      method.should_receive(:call).twice
      subject.call(method)
    end

    it "does not retry the method if it succeeds" do
      method.should_receive(:call).once.and_return(true)
      subject.call(method)
    end
  end

  describe "#wait" do
    let(:options) { { tries: 4, delay: 1, backoff: 2 } }

    it "waits for the specified delay on failure" do
      subject.should_receive(:sleep).at_least(1).times
      subject.call(method)
    end

    it "mulitplies the delay by the backoff each iteration" do
      [ 1, 2, 4, 8 ].each do |actual_delay|
        subject.should_receive(:sleep).with(actual_delay).once
      end
      subject.call(method)
    end
  end
end
