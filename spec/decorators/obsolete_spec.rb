require 'spec_helper'
require 'method_decorators/obsolete'
require 'stringio'

describe MethodDecorators::Obsolete do
  let(:method) { double(:method, :call => 'return value of original method', :name => 'obsolete_method') }

  describe '#call' do
    subject { MethodDecorators::Obsolete.new }

    it 'calls original method' do
      method.should_receive(:call)
      subject.call(method, nil)
    end

    it 'warns' do
      subject.should_receive(:warn)
      subject.call(method, nil)
    end

    context 'when string given on initializing' do
      subject { MethodDecorators::Obsolete.new('custom message') }

      it 'warns with given string' do
        subject.should_receive(:warn).with('custom message')
        subject.call(method, nil)
      end
    end

    context 'when block given on initializing' do
      subject { MethodDecorators::Obsolete.new {|klass, method| "#{klass}##{method}"} }

      it 'warns with message formatted by the block' do
        subject.should_receive(:warn).with('NilClass#obsolete_method')
        subject.call(method, nil)
      end
    end

    context 'when object which has #call method given on initializing' do
      subject { MethodDecorators::Obsolete.new(->(klass, method) { "#{klass}##{method}" }) }

      it 'warns with message formatted by the object' do
        subject.should_receive(:warn).with('NilClass#obsolete_method')
        subject.call(method, nil)
      end
    end
  end

  describe 'acceptance' do
    before do
      $stderr = StringIO.new
      subject.obsolete_method
      $stderr.rewind
    end

    let(:klass) {
      Class.new Base do
        +MethodDecorators::Obsolete
        def obsolete_method
          'return value of original method'
        end
      end
    }
    subject { klass.new }

    it 'warns' do
      expect($stderr.read).to eq("#{klass}#obsolete_method is obsolete\n")
    end

    context 'when string given on initializing' do
      let(:klass) {
        Class.new Base do
          +MethodDecorators::Obsolete.new('custom message')
          def obsolete_method
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
          +MethodDecorators::Obsolete.new {|class_name, method_name| "#{class_name}##{method_name} is obsolete"}
          def obsolete_method
            'return value of original method'
          end
        end
      }

      it 'warns with message formatted by the block' do
        expect($stderr.read).to eq("#{klass}#obsolete_method is obsolete\n")
      end
    end

    context 'when object witch has #call method givn on initializing' do
      let(:klass) {
        Class.new Base do
          +MethodDecorators::Obsolete.new(->(class_name, method_name) {"#{class_name}##{method_name} is obsolete"})
          def obsolete_method
            'return value of original method'
          end
        end
      }

      it 'warns with message formatted by the object' do
        expect($stderr.read).to eq("#{klass}#obsolete_method is obsolete\n")
      end
    end
  end
end
