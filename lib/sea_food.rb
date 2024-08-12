# frozen_string_literal: true

require 'active_model'
require 'sea_food/version'

# Namespace for all objects in SeaFood
module SeaFood
  autoload :Error, 'sea_food/error'
  autoload :Form, 'sea_food/form'
  autoload :Service, 'sea_food/service'
end
