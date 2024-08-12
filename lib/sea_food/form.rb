module SeaFood
  class Form
    include ::ActiveModel::Model

    def validate(options = {})
      valid? && validate_model(options)
    end

    def save(options = {})
      model.save(options) if valid?
    end

    def save!(options = {})
      model.save!(options) if valid?
    end

    private

    attr_accessor :model

    def validate_model(_options)
      promote_errors(model) if model.invalid?
    end

    def promote_errors(model)
      SeaFood::Error.new(model.errors.full_message, model.errors)
    end
  end
end
