class Retry < MethodDecorator
  DEFAULTS = { tries: 2, delay: 1, backoff: 1 }.freeze

  attr_accessor :tries, :delay, :backoff
  attr_accessor :remaining, :result, :til_next

  def initialize(options = {})
    options = DEFAULTS.merge(options)
    self.tries   = options[:tries]
    self.delay   = options[:delay]
    self.backoff = options[:backoff]
  end

  def call(orig, *args, &blk)
    reset
    try(orig, *args, &blk) until success? or exhausted?
  end

  private

  def reset
    self.result    = nil
    self.remaining = self.tries
    self.til_next  = self.delay
  end

  def try(orig, *args, &blk)
    self.remaining -= 1
    self.result = orig.call(*args, &blk)
    wait unless success?
    result
  end

  def wait
    sleep(til_next)
    self.til_next *= backoff
  end

  def success?
    !!result
  end

  def exhausted?
    self.remaining == 0
  end
end
