require 'spec_helper'
require 'method_decorators/deprecated'
require 'stringio'

describe MethodDecorators::Deprecated do
  let(:method) { double(:method, :call => 'return value of original method', :name => 'deprecated_method') }

  describe '#call' do
    subject { MethodDecorators::Deprecated.new }

    it 'calls original method' do
      method.should_receive(:call)
      subject.call(method, nil)
    end

    it 'warns' do
      subject.should_receive(:warn)
      subject.call(method, nil)
    end

    context 'when string given on initializing' do
      subject { MethodDecorators::Deprecated.new('custom message') }

      it 'warns with given string' do
        subject.should_receive(:warn).with('custom message')
        subject.call(method, nil)
      end
    end

    context 'when block given on initializing' do
      subject { MethodDecorators::Deprecated.new {|klass, method| "#{klass}##{method}"} }

      it 'warns with message formatted by the block' do
        subject.should_receive(:warn).with('NilClass#deprecated_method')
        subject.call(method, nil)
      end
    end

    context 'when object which has #call method given on initializing' do
      subject { MethodDecorators::Deprecated.new(lambda { |klass, method| "#{klass}##{method}" }) }

      it 'warns with message formatted by the object' do
        subject.should_receive(:warn).with('NilClass#deprecated_method')
        subject.call(method, nil)
      end
    end
  end

  describe 'acceptance' do
    before do
      $stderr = StringIO.new
      subject.deprecated_method
      $stderr.rewind
    end

    let(:klass) {
      Class.new Base do
        +MethodDecorators::Deprecated
        def deprecated_method
          'return value of original method'
        end
      end
    }
    subject { klass.new }

    it 'warns' do
      expect($stderr.read).to eq("#{klass}#deprecated_method is deprecated\n")
    end

    context 'when string given on initializing' do
      let(:klass) {
        Class.new Base do
          +MethodDecorators::Deprecated.new('custom message')
          def deprecated_method
            'return value of original method'
          end
        end
      }

      it 'warns with given string' do
        expect($stderr.read).to eq("custom message\n")
      end
    end

    context 'when block given on initializing' do
      let(:klass) {
        Class.new Base do
          +MethodDecorators::Deprecated.new {|class_name, method_name| "#{class_name}##{method_name} is deprecated"}
          def deprecated_method
            'return value of original method'
          end
        end
      }

      it 'warns with message formatted by the block' do
        expect($stderr.read).to eq("#{klass}#deprecated_method is deprecated\n")
      end
    end

    context 'when object witch has #call method givn on initializing' do
      let(:klass) {
        Class.new Base do
          +MethodDecorators::Deprecated.new(lambda { |class_name, method_name| "#{class_name}##{method_name} is deprecated" })
          def deprecated_method
            'return value of original method'
          end
        end
      }

      it 'warns with message formatted by the object' do
        expect($stderr.read).to eq("#{klass}#deprecated_method is deprecated\n")
      end
    end
  end
end
