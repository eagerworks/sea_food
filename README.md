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

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/sea_food. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the SeaFood project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/sea_food/blob/master/CODE_OF_CONDUCT.md).
