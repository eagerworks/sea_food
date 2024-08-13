require 'bundler/setup'

require 'active_record'
require 'database_cleaner/active_record'
require 'debug'

ActiveRecord::Base.establish_connection adapter: 'sqlite3', database: ':memory:'

require 'sea_food'
load File.dirname(__FILE__) + '/support/schema.rb'
require File.dirname(__FILE__) + '/support/form/user_form.rb'
require File.dirname(__FILE__) + '/support/form/address_form.rb'
require File.dirname(__FILE__) + '/support/user.rb'
require File.dirname(__FILE__) + '/support/address.rb'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

  def klass(class_name, parent = Object, &block)
    klass = Class.new(parent)
    klass.class_exec(&block)
    self.class.const_set class_name, klass
  end

  def remove_klass(klass)
    self.class.send(:remove_const, klass)
  end
end
