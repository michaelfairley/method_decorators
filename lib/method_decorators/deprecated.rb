require 'method_decorators'

module MethodDecorators
  # Example:
  #   class MyClass
  #     extend MethodDecorators
  #
  #     +MethodDecorators::Deprecated
  #     def deprecated_method
  #       brand_new_method
  #     end
  #   end
  # When deprecated_method is called, message
  #   "MyClass#deprecated_method is deprecated"
  # is output.
  #
  # Another example:
  #   class MyClass
  #     extend MethodDecorators
  #
  #     +MethodDecorators::Deprecated.new('deprecated_method will be removed in the future')
  #     def deprecated_method
  #       brand_new_method
  #     end
  #   end
  # Above output given message
  #   "deprecated_method will be removed in the future"
  #
  # Custom message example:
  #   class MyClass
  #     extend MethodDecorators
  #
  #     +MethodDecorators::Deprecated.new {|class_name, method_name| "#{class_name}##{method_name} will be removed in the future. Use #{class_name}#brand_new_method instead"}
  #     def deprecated_method
  #       brand_new_method
  #     end
  #   end
  # Outputs
  #   "MyClass#deprecated_method will be removed in the future. Use MyClass#brand_new_method instead"
  # As you see, you can use class name as the first argument and method name as the second in the block.
  #
  # Formatter example:
  #   class Formatter2
  #     def call(class_name, method_name)
  #       "#{class_name}##{method_name} will be removed after the next version. Use #{class_name}#brand_new_method instead"
  #     end
  #   end
  #   class MyClass
  #     extend MethodDecorators
  #
  #     formatter1 = ->(class_mane, method_name) {"#{class_name}##{method_name} will be removed in the next version. Use #{class_name}#brand_new_method instead"}
  #     +MethodDecorators::Deprecated.new(formatter1)
  #     def very_old_method
  #       brand_new_method
  #     end
  #
  #     + MethodDecorators::Deprecated.new(Formatter2.new)
  #     def deprecated_method
  #       brand_new_method
  #     end
  #   end
  # Outputs
  #   "MyClass#deprecated_method will be removed in the future. Use MyClass#brand_new_method instead"
  # You can give any object which responds to method "call" like Proc.
  class Deprecated < Decorator
    DEFAULT_FORMATTER = lambda {|class_name, method_name| "#{class_name}##{method_name} is deprecated"}
    def initialize(message=nil, &blk)
      @message = message || blk || DEFAULT_FORMATTER
    end

    def call(orig, this, *args, &blk)
      warn message(this.class, orig.name)
      orig.call(*args, &blk)
    end

    def message(class_name, method_name)
      if @message.respond_to? :call
        @message.call(class_name, method_name)
      else
        @message.to_s
      end
    end
  end
end
