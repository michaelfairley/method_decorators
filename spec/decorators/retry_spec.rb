require 'spec_helper'
require 'method_decorators/retry'

describe MethodDecorators::Retry do
  let(:method) { double(:method, :call => false) }
  subject { MethodDecorators::Retry.new(3) }

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

    context 'when :sleep is given to #initialize' do
      subject { MethodDecorators::Retry.new(3, :sleep => 5) }

      it 'sleeps after failures before retrying' do
        method.stub(:call) { raise ArgumentError }
        subject.should_receive(:sleep).with(5).exactly(2).times
        expect { subject.call(method, nil) }.to raise_error(ArgumentError)
      end
    end
  end

  describe "acceptance" do
    let(:klass) do
      Class.new Base do
        +MethodDecorators::Retry.new(3)
        def do_it(magic_number)
          @times ||= 0
          @times += 1
          raise  if @times == magic_number
          @times
        end
      end
    end
    subject { klass.new }

    it 'retries calls to the method' do
      subject.do_it(1).should == 2
    end
  end
end
