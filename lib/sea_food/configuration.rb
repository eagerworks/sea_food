module SeaFood
  class Configuration
    attr_accessor :enforce_interface

    def initialize
      @enforce_interface = false # Default value
    end
  end

  # Method to access the configuration
  def self.configuration
    @configuration ||= Configuration.new
  end

  # Method to configure the gem
  def self.configure
    yield(configuration) if block_given?
  end
end
