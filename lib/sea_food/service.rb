# SeaFood::Service class serves as a base for creating services.
# It standardizes the way services are called.
module SeaFood
  class Service
    attr_reader :params, :result

    # Initializes the service.
    # @param params [Hash] The parameters to be passed to the service.
    def initialize(params = {})
      @params = params
      @result = ServiceResult.new
    end

    class << self
      # Calls the service and handles any exceptions.
      # @param args [Hash] Arguments to pass to the service.
      # @return [ServiceResult] The result of the service call.
      def call(params = {})
        service = new(params)
        service.call
        service.result
      rescue ServiceError => e
        service.result
      end
    end

    # The main method to be implemented by subclasses.
    def call
      raise NotImplementedError, 'Subclasses must implement the call method'
    end

    protected

    # Marks the service as failed.
    # @param data [Any] Optional data to be returned in the result.
    def fail(errors = nil)
      @result = ServiceResult.new(success: false, errors: errors)
    end

    # Marks the service as successful.
    # @param data [Any] Optional data to be returned in the result.
    def success(data = nil)
      @result = ServiceResult.new(success: true, data: data)
    end

    # Marks the service as failed and stop the execution of the service.
    # @param errors [Any] Errors to be returned in the result.
    def fail!(errors = nil)
      @result = ServiceResult.new(success: false, errors: errors)
      raise ServiceError, @result
    end

    class ServiceResult
      attr_reader :success, :data

      # Initializes the ServiceResult.
      # @param success [Boolean] Indicates if the service call was successful.
      # @param data [Any] The data returned by the service.
      def initialize(success: true, data: nil)
        @success = success
        @data = data
      end

      # Checks if the service call was successful.
      # @return [Boolean] True if successful, false otherwise.
      def succeeded?
        success
      end

      # Checks if the service call failed.
      # @return [Boolean] True if failed, false otherwise.
      def failed?
        !success
      end
    end

    class ServiceError < StandardError; end
  end
end
