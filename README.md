# MethodDecorators

Python's function decorators for Ruby.

## Installation
`gem install method_decorators`

## Usage

### Using a decorator
Extend MethodDecorators in a class where you want to use them, and then stick `+DecoratorName` before your method declaration to use it.

```ruby
class Math
  extend MethodDecorators

  +Memoized
  def fib(n)
    if n <= 1
      1
    else
      fib(n - 1) * fib(n - 2)
    end
  end
end
```

You can also decorate with an instance of a decorator, rather than the class. This is useful for configuring specific options for the decorator.

```ruby
class ExternalService
  extend MethodDecorators

  +Retry.new(3)
  def request
    ...
  end
end
```

You can also set multiple decorators for your methods.

```ruby
class ExternalService
  extend MethodDecorators

  +Retry.new(3)
  +Within.new(2)
  def request
    ...
  end
end
```

### Included decorators

Include these with `require 'method_decorators/decorators/name_of_decorator'`, or all at once with `require 'method_decorators/decorators'`.

- Memoize - caches the result of the method for each arg combination it's called with
- Retry - retries the method up to n (passed in to the constructor) times if the method errors
- Within - times outs if a request doesn't complete within n seconds
- Precondition - raises an error if the precondition (passed as a block) is not met

### Defining a decorator

```ruby
class Transactional < MethodDecorator
  def call(wrapped, this, *args, &blk)
    ActiveRecord::Base.transaction do
      wrapped.call(*args, &blk)
    end
  end
end
```

## License
MethodDecorators is available under the MIT license and is freely available for all use, including personal, commercial, and academic. See LICENSE for details.
