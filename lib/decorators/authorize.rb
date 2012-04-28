class Authorize < MethodDecorator
  attr_accessor :auth

  def self.with(&blk)
    new.tap do |this| this.auth = Proc.new(blk) end
  end

  def call(orig, *args, &blk)
    orig.call(*args, &blk) if authorized?(orig.receiver, *args)
  end

  def authorized?(context, *args)
    return false if auth.nil?
    context.instance_exec(*args, &auth)
  end
end
