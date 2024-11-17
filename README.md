# SeaFood

The sea_food gem is a Ruby library designed to enhance the development of service and form objects in Ruby applications. Representing SErvice Objects And Form Object Design patterns, this gem facilitates the separation of business logic and data validations from ActiveRecord models. 
P.S. Jian Yang would be proud; Erlich Bachman, not so much.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sea_food'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sea_food

## Usage

### Service usage
```ruby
class Invoices::ApproveService < SeaFood::Service
  def initialize(invoice:, user:)
    @invoice = invoice
    @user = user
  end

  def call
    fail!("You are not authorized to approve invoices") unless authorized?

    @invoice.update!(status: :approved)
    success(invoice: @invoice)
  end
end

result = Invoices::ApproveService.call(invoice: invoice, user: user)
result.success?
#=> true
result.invoice
#=> <Invoice(...>
```
If you want to enforce the interface and not allow users to use `call`
without arguments defined in the `initialize` you can add an initializer.
```ruby
# initializers/sea_food.rb
SeaFood.configure do |config|
  config.enforce_interface = true
end
```
It will raise an `ArgumentError`.


### Handling Success and Failure
#### Using success and fail
`success(data):` Marks the service result as successful and optionally provides data.
`fail(data):` Marks the service result as a failure but continues executing the call method.
`fail!(data):` Marks the service result as a failure and immediately exits the call method.
#### Example: Using fail followed by success
```ruby
  class TestFailService < SeaFood::Service
    def initialize(email:)
      @email = email
    end

    def call
      fail(email: 'hi@example.com')
      success(email: @email)
    end
  end

  result = TestFailService.call(email: 'service@example.com')

  puts result.success? # => true
  puts result.email    # => 'service@example.com'
```
In this example:

The fail method sets the result to failure but allows the method to continue.
The subsequent success call overrides the failure, resulting in a successful outcome.

#### Example: Using fail! to Exit Early
```ruby
class TestFailBangService < SeaFood::Service
  def initialize(email:)
    @email = email
  end

  def call
    fail!(email: 'hi@example.com')
    success(email: @email) # This line is not executed
  end
end

result = TestFailBangService.call(email: 'service@example.com')

puts result.success? # => false
puts result.email    # => 'hi@example.com'
```

The `fail!` method immediately exits the call method.
The service result is a failure, and subsequent code in call is not executed.
Nested Services
You can call other services within a service. The behavior depends on whether you use `call` or `call!`.
#### Summary of call vs. call!
`call`: Executes the service and returns the result. Does not raise an exception if the service fails.
`call!`: Executes the service and raises an exception if the service fails. Useful for propagating failures in nested services.

#### Using call (Non-Bang Method)
Failures in nested services do not automatically propagate to the parent service.


```ruby
  class InnerService < SeaFood::Service
    def initialize(email:)
      @email = email
    end

    def call
      fail!(email: @email)
    end
  end

  class OuterService < SeaFood::Service
    def initialize(email:)
      @email = email
    end

    def call
      InnerService.call(email: 'inner@example.com')
      success(email: @email)
    end
  end

  result = OuterService.call(email: 'outer@example.com')

  puts result.success? # => true
  puts result.email    # => 'outer@example.com'
```
*Explanation:*

`InnerService` fails using `fail!`.
`OuterService` calls `InnerService` using `call`.
Since `call` does not raise an exception on failure, `OuterService` continues and succeeds.
#### Using `call!` (Bang Method)
Failures in nested services propagate to the parent service when using `call!`.

```ruby
  class InnerService < SeaFood::Service
    def initialize(email:)
      @email = email
    end

    def call
      fail!(email: @email)
    end
  end

  class OuterService < SeaFood::Service
    def initialize(email:)
      @email = email
    end

    def call
      InnerService.call!(email: 'inner@example.com')
      success(email: @email) # This line is not executed
    end
  end

  result = OuterService.call(email: 'outer@example.com')

  puts result.success? # => false
  puts result.email    # => 'inner@example.com'
```
*Explanation:*

`InnerService` fails using `fail!`.
`OuterService` calls `InnerService` using call!.
The failure from `InnerService` propagates, causing `OuterService` to fail.
#### Handling Failures in Nested Services
You can handle failures from nested services by checking their result.

```ruby
class InnerService < SeaFood::Service
  def initialize(value:)
    @value = value
  end

  def call
    if @value < 0
      fail!(error: 'Negative value')
    else
      success(value: @value)
    end
  end
end

class OuterService < SeaFood::Service
  def initialize(value:)
    @value = value
  end

  def call
    result = InnerService.call(value: @value)

    if result.fail?
      fail!(error: result.error)
    else
      success(value: result.value * 2)
    end
  end
end

result = OuterService.call(value: -1)

puts result.success?   # => false
puts result.error      # => 'Negative value'
```
*Explanation:*

`OuterService` checks the result of `InnerService`.
If `InnerService` fails, `OuterService` handles it accordingly.

#### Accessing Result Data
The result object allows you to access data provided in success or fail calls using method syntax.

```ruby
class ExampleService < SeaFood::Service
  def call
    success(message: 'Operation successful', value: 42)
  end
end

result = ExampleService.call

puts result.success?   # => true
puts result.message    # => 'Operation successful'
puts result.value      # => 42
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/sea_food. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the SeaFood project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/sea_food/blob/master/CODE_OF_CONDUCT.md).
