require 'spec_helper'

class Base
  extend MethodDecorators
end

describe Authorize do
  subject { klass.new }

  describe "decorating with a simple decorator" do
    let(:klass) do
      Class.new Base do
        +Authorize.with { has_clearance? }
        def protected
          :secret
        end

        +Authorize.with { |key| confirmed?(key) }
        def calculated_protection(key)
          key.to_s
        end
      end
    end

    it "returns false when authorization fails" do
      subject.stub(:has_clearance?).and_return(false)
      subject.protected.should be_false
    end

    it "executes the method when authorization succeeeds" do
      subject.stub(:has_clearance?).and_return(true)
      subject.protected.should eq :secret
    end

    it "passes the original arguments to the authorization block" do
      subject.should_receive(:confirmed?).with(:skeleton).and_return(true)
      subject.calculated_protection(:skeleton).should eq "skeleton"
    end
  end
end
