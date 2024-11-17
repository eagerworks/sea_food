# SeaFood::Service class serves as a base for creating services.
# It standardizes the way services are called.
module SeaFood
  class Service
    attr_reader :params, :result

    # Initializes the service.
    # @param params [Hash] The parameters to be passed to the service.
    def initialize(params = {})
      if SeaFood.configuration.enforce_interface
        raise NotImplementedError,
              'Subclasses must implement the initialize method ' \
              'because `enforce_interface` is set to true'
      end
      @params = params
      @result = ServiceResult.new
    end

    class << self
      # Calls the service and handles any exceptions.
      # @param args [Hash] Arguments to pass to the service.
      # @return [ServiceResult] The result of the service call.
      def call(params = {})
        service = new(**params)
        service.call
        service.result || ServiceResult.new
      rescue ServiceError => e
        service.result || e.try(:result)
      end

      def call!(params = {})
        result = call(params)
        return result || ServiceResult.new unless result.fail?

        raise ServiceError, result
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

    # Validates the service using form objects.
    # @param [ { key: form [ActiveModel::Model] }] The form objects to validate.
    def validate_with(key, form)
      fail({ key => form.errors.messages }) unless form.valid?
    end

    # Validates the service using form objects.
    # @param [ { key: form [ActiveModel::Model] }] The form objects to validate.
    def validate_with!(key, form)
      fail!({ key => form.errors.messages }) unless form.valid?
    end

    def validate_pipeline(pipeline)
      pipeline.each do |key, form|
        fail_and_merge({ key => form.errors.messages }) unless form.valid?
      end
      fail!(@result.errors) if @result.failed?
    end

    class ServiceResult
      attr_reader :success, :data, :errors

      # Initializes the ServiceResult.
      # @param success [Boolean] Indicates if the service call was successful.
      # @param data [Any] The data returned by the service.
      def initialize(success: true, data: nil, errors: nil)
        @success = success
        @data = (data || {}).with_indifferent_access
        @errors = (errors.to_h || {}).with_indifferent_access
      end

      # Checks if the service call was successful.
      # @return [Boolean] True if successful, false otherwise.
      def succeeded?
        success
      end

      alias success? succeeded?

      # Checks if the service call failed.
      # @return [Boolean] True if failed, false otherwise.
      def failed?
        !success
      end

      alias fail? failed?

      # :rubocop:disable Style/MissingRespondToMissing
      def method_missing(key)
        if succeeded?
          @data[key]
        else
          @errors[key]
        end
      end
    end

    class ServiceError < StandardError
      attr_reader :result

      def initialize(result)
        @result = result
      end
    end

    private

    def fail_and_merge(errors)
      @result = if @result.blank?
                  ServiceResult.new(success: false, errors: errors)
                else
                  ServiceResult.new(success: false, errors: errors.merge!(@result.errors))
                end
    end
  end
end
