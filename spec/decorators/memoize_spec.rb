require 'spec_helper'

class Base
  extend MethodDecorators
end

describe Memoize do
  subject { klass.new }

  describe "decorating with a simple decorator" do
    let(:klass) do
      Class.new Base do
        +Memoize
        def foo(bar)
          baz(bar)
        end

        def baz(bat)
          bat
        end
      end
    end

    it "calculates the value the first time the arguments are supplied" do
      subject.should_receive(:baz)
      subject.foo(1)
    end

    it "memoizes the return value and skips calculation" do
      subject.foo(1)
      subject.should_not_receive(:baz)
      subject.foo(1).should eq 1
    end

  end
end
