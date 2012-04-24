require 'spec_helper'

class Base
  extend MethodDecorators
end

describe MethodDecorators do
  subject { klass.new }

  describe "decorating with a simple decorator" do
    let(:klass) do
      Class.new Base do
        +Stringify
        def three
          3
        end
      end
    end

    it "works" do
      subject.three.should == '3'
    end
  end

  describe "decorating with a decorator that takes arguments" do
    let(:klass) do
      Class.new Base do
        +AddN.new(1)
        def four
          3
        end
      end
    end

    it "works" do
      subject.four.should == 4
    end
  end

  describe "decorating an instance method" do
    describe "that is public" do
      let(:klass) do
        Class.new Base do
          +Stringify
          def three
            3
          end
        end
      end

      it "works" do
        subject.three.should == '3'
      end
    end

    describe "that is protected" do
      let(:klass) do
        Class.new Base do
        protected
          +Stringify
          def three
            3
          end
        end
      end

      it "works" do
        subject.protected_methods.map(&:to_s).should include 'three'
        subject.send(:three).should == '3'
      end
    end

    describe "that is private" do
      let(:klass) do
        Class.new Base do
        private
          +Stringify
          def three
            3
          end
        end
      end

      it "works" do
        subject.private_methods.map(&:to_s).should include 'three'
        subject.send(:three).should == '3'
      end
    end

    describe "with multiple decorators" do
      let(:klass) do
        Class.new Base do
          +Stringify
          +AddN.new(3)
          def six
            3
          end
        end
      end

      it "works" do
        subject.six.should == '6'
      end    
    end

    describe "that takes args" do
      let(:klass) do
        Class.new Base do
          +Stringify
          def sum(a, b)
            a + b
          end
        end
      end

      it "works" do
        subject.sum(1, 2).should == "3"
      end
    end

    describe "that takes a block" do
      let(:klass) do
        Class.new Base do
          +Stringify
          def double(&blk)
            blk.call + blk.call
          end
        end
      end

      it "works" do
        subject.double{ 2 }.should == '4'
      end
    end

    describe "with a decorator that messes with the args" do
      let(:klass) do
        Class.new Base do
          +Reverse
          def echo(a, b)
            [a, b]
          end
        end
      end

      it "works" do
        subject.echo(1, 2).should == [2, 1]
      end
    end
  end

  describe "decorating a singleton method" do
    subject { klass }

    describe "that is public" do
      let(:klass) do
        Class.new Base do
          +Stringify
          def self.three
            3
          end
        end
      end

      it "works" do
        subject.three.should == '3'
      end
    end

    describe "that is private" do
      let(:klass) do
        Class.new Base do
          +Stringify
          def self.three
            3
          end
          private_class_method :three
        end
      end

      it "works" do
        subject.private_methods.map(&:to_s).should include 'three'
        subject.send(:three).should == '3'
      end
    end

    describe "with multiple decorators" do
      let(:klass) do
        Class.new Base do
          +Stringify
          +AddN.new(3)
          def self.six
            3
          end
        end
      end

      it "works" do
        subject.six.should == '6'
      end    
    end

    describe "that takes args" do
      let(:klass) do
        Class.new Base do
          +Stringify
          def self.sum(a, b)
            a + b
          end
        end
      end

      it "works" do
        subject.sum(1, 2).should == "3"
      end
    end

    describe "that takes a block" do
      let(:klass) do
        Class.new Base do
          +Stringify
          def self.double(&blk)
            blk.call + blk.call
          end
        end
      end

      it "works" do
        subject.double{ 2 }.should == '4'
      end
    end

    describe "with a decorator that messes with the args" do
      let(:klass) do
        Class.new Base do
          +Reverse
          def self.echo(a, b)
            [a, b]
          end
        end
      end

      it "works" do
        subject.echo(1, 2).should == [2, 1]
      end
    end
  end
end
