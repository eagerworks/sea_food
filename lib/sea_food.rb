# frozen_string_literal: true

require 'active_model'
require 'sea_food/version'
require 'sea_food/configuration'

# Namespace for all objects in SeaFood
module SeaFood
  autoload :Error, 'sea_food/error'
  autoload :Form, 'sea_food/form'
  autoload :Service, 'sea_food/service'

  # Yields SeaFood::Configuration instance.
  def configure
    yield configuration if block_given?
  end

  # Public: Returns SeaFood::Configuration instance.
  def configuration
    @configuration ||= Configuration.new
  end

  # Public: Sets SeaFood::Configuration instance.
  def configuration=(configuration)
    # need to reset SeaFood instance if configuration changes
    self.instance = nil
    @configuration = configuration
  end
end
