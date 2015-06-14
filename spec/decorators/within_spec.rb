require 'spec_helper'
require 'method_decorators/within'

describe MethodDecorators::Within do
  let(:method) { double(:method, :call => false) }
  subject { MethodDecorators::Within.new(2) }

  describe "#call" do
    it "raises when the timeout seconds have elapsed" do
      method.stub(:call){ sleep 3 }
      expect{ subject.call(method, nil) }.to raise_error(Timeout::Error)
    end

    it "does not raise when the method has finished execution before timeout" do
      method.stub(:call){ sleep 1 }
      expect{ subject.call(method, nil) }.to_not raise_error
    end

    context 'when an exception class is given in #initialize' do
      subject { MethodDecorators::Within.new(1, ArgumentError) }

      it 'raises the given exception if timeout seconds have elapsed' do
        allow(method).to receive(:call) { sleep 2 }
        expect { subject.call(method, nil) }.to raise_error(ArgumentError)
      end
    end
  end

  describe "acceptance" do
    let(:klass) do
      Class.new Base do
        +MethodDecorators::Within.new(2)
        def do_it(execution_period)
          sleep(execution_period)
        end
      end
    end
    subject { klass.new }

    context "with longer execution period" do
      it "raises if the timeout period has elapsed" do
        expect{ subject.do_it(3) }.to raise_error(Timeout::Error)
      end

      context 'and given an exception' do
        let(:klass) do
          Class.new(Base) do
            +MethodDecorators::Within.new(1, ArgumentError)
            def do_it(execution_period)
              sleep(execution_period)
            end
          end
        end

        it 'raises the given exception' do
          expect { subject.do_it(2) }.to raise_error(ArgumentError)
        end
      end
    end

    context "with shorter execution period" do
      it "finishes within the timeout period" do
        expect{ subject.do_it(1) }.to_not raise_error
      end
    end
  end
end
