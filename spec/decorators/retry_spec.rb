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

    context 'when :exceptions is given to #initialize' do
      subject do
        MethodDecorators::Retry.new(3, :exceptions => [ArgumentError])
      end

      context 'and the raised exception matches' do
        before do
          allow(method).to receive(:call) { raise ArgumentError }
        end

        it 'retries' do
          expect(method).to receive(:call).exactly(3).times
          expect { subject.call(method, nil) }.to raise_error(ArgumentError)
        end
      end

      context 'and the raised exception does not match' do
        before do
          allow(method).to receive(:call) { raise IndexError }
        end

        it 'does not retry' do
          expect(method).to receive(:call).once
          expect { subject.call(method, nil) }.to raise_error(IndexError)
        end
      end
    end
  end

  describe "acceptance" do
    def create_class(options = {})
      Class.new(Base) do
        attr_reader :times

        +MethodDecorators::Retry.new(3, options)
        def do_it(magic_number)
          @times ||= 0
          @times += 1
          raise if @times == magic_number
          @times
        end
      end
    end

    let(:klass) { create_class }
    subject { klass.new }

    it 'retries calls to the method' do
      subject.do_it(1).should == 2
    end

    context 'when :exceptions is given to #initialize' do
      let(:klass) { create_class(:exceptions => [ArgumentError]) }

      it 'does not retry if the raised exception does not match' do
        expect { subject.do_it(1) }.to raise_error
        expect(subject.times).to eq(1)
      end
    end
  end
end
