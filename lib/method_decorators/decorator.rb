module MethodDecorators
  class Decorator
    @@current_decorators = []

    def self.current_decorators
      decs = @@current_decorators
      @@current_decorators = []
      decs
    end

    def self.+@
      +new
    end

    def +@
      @@current_decorators.unshift(self)
    end
  end
end
