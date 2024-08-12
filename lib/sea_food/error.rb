module SeaFood
  class Error < StandardError
    attr_reader :result

    def initialize(message, params = {})
      @result = params[:result]
      super(message)
    end
  end
end
