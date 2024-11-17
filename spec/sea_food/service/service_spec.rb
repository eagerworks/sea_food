# frozen_string_literal: true

RSpec.describe 'Service usages' do
  ######
  # Test .call need override
  ######

  it '.call needs to be overridden' do
    TestExampleService = Class.new(SeaFood::Service) do
    end

    expect { TestExampleService.call }.to raise_error(
      NotImplementedError
    ).with_message('Subclasses must implement the call method')
  end

  ######
  # Test .call
  ######

  it '.call - success by default' do
    TestSuccessByDefaultService = Class.new(SeaFood::Service) do
      def call; end
    end

    result = TestSuccessByDefaultService.call(email: 'service@example.com')

    expect(result).to be_success
  end

  it '.call with #success && data' do
    TestSuccessService = Class.new(SeaFood::Service) do
      def call
        success(email: params[:email])
      end
    end

    result = TestSuccessService.call(email: 'service@example.com')

    expect(result).to be_success
    expect(result.email).to eq('service@example.com')
  end

  it '.call with #fail!' do
    TestFailService = Class.new(SeaFood::Service) do
      def call
        fail!(email: params[:email])
      end
    end

    result = TestFailService.call(email: 'service@example.com')

    expect(result).to be_fail
    expect(result.email).to eq('service@example.com')
  end

  it '.call - fail on raising error' do
    TestFailOnRaiseErrorService = Class.new(SeaFood::Service) do
      def call
        raise StandardError, 'Something wrong'
      end
    end

    expect { TestFailOnRaiseErrorService.call }.to raise_error(
      StandardError
    ).with_message('Something wrong')
  end

  ######
  # Test enforcing the interface of the service
  ######

  context 'when the configuration is set to enforce the interface' do
    before do
      SeaFood.configure do |config|
        config.enforce_interface = true
      end
    end

    it 'rasies an error when the #initialize method is not implemented' do
      TestService = Class.new(SeaFood::Service) do
        def call; end
      end

      expect { TestService.call }.to raise_error(
        NotImplementedError
      ).with_message(
        'Subclasses must implement the initialize '\
        'method because `enforce_interface` is set to true'
      )
    end

    it 'does not rasies an error when the #initialize method is implemented' do
      TestService = Class.new(SeaFood::Service) do
        def initialize; end
        def call; end
      end

      expect { TestService.call }.not_to raise_error(
        NotImplementedError
      )
    end

    it '.call - fails on missing arguments' do
      TestFailOnMissingArgsService = Class.new(SeaFood::Service) do
        def initialize(email:)
          @email = email
        end

        def call
          success(email: email)
        end
      end

      expect { TestFailOnMissingArgsService.call }.to raise_error(
        ArgumentError
      ).with_message('missing keyword: :email')
    end

    it '.call - success with arguments' do
      TestSuccessWithArgsService = Class.new(SeaFood::Service) do
        def initialize(email:)
          @email = email
        end

        def call
          success(email: @email)
        end
      end

      result = TestSuccessWithArgsService.call(email: 'fede@example.com')
      expect(result).to be_success
      expect(result.email).to eq('fede@example.com')
    end

    it '.call - success default with arguments ' do
      TestSuccessWithArgsService = Class.new(SeaFood::Service) do
        def initialize(email:)
          @email = email
        end

        def call; end
      end

      result = TestSuccessWithArgsService.call(email: 'fede@example.com')
      expect(result).to be_success
      expect(result.email).to be_nil
    end

    ######
    # Test the difference behavior of #success #fail #fail!
    ######

    it 'call #success twice' do
      TestSuccessService = Class.new(SeaFood::Service) do
        def initialize(email:)
          @email = email
        end

        def call
          success(email: 'hi@example.com')
          success(email: @email)
        end
      end

      result = TestSuccessService.call(email: 'service@example.com')

      expect(result).to be_success
      expect(result.email).to eq('service@example.com')
    end

    it 'call #fail twice' do
      TestFailService = Class.new(SeaFood::Service) do
        def initialize(email:)
          @email = email
        end

        def call
          fail(email: 'hi@example.com')
          fail(email: @email)
        end
      end

      result = TestFailService.call(email: 'service@example.com')

      expect(result).to be_fail
      expect(result.email).to eq('service@example.com')
    end

    it 'call #fail! twice' do
      TestFailService = Class.new(SeaFood::Service) do
        def initialize(email:)
          @email = email
        end

        def call
          fail!(email: 'hi@example.com')
          fail!(email: @email)
        end
      end

      result = TestFailService.call(email: 'service@example.com')

      expect(result).to be_fail
      expect(result.email).to eq('hi@example.com')
    end

    it '#fail then #success' do
      TestFailService = Class.new(SeaFood::Service) do
        def initialize(email:)
          @email = email
        end

        def call
          fail(email: 'hi@example.com')
          success(email: @email)
        end
      end

      result = TestFailService.call(email: 'service@example.com')

      expect(result).to be_success
      expect(result.email).to eq('service@example.com')
    end

    it '#fail! then #success!' do
      TestFailService = Class.new(SeaFood::Service) do
        def initialize(email:)
          @email = email
        end

        def call
          fail!(email: 'hi@example.com')
          success(email: @email)
        end
      end

      result = TestFailService.call(email: 'service@example.com')

      expect(result).to be_fail
      expect(result.email).to eq('hi@example.com')
    end

    context 'testing nested services with call' do
      it 'it fails on the first service but not on the second one' do
        TestInnerFailService = Class.new(SeaFood::Service) do
          def initialize(email:)
            @email = email
          end

          def call
            fail!(email: @email)
          end
        end

        TestParentFailService = Class.new(SeaFood::Service) do
          def initialize(email:)
            @email = email
          end

          def call
            TestInnerFailService.call(email: 'inner@service.com')
            success(email: @email)
          end
        end

        result = TestParentFailService.call(email: 'outer@service.com')

        expect(result).to be_success
        expect(result.email).to eq('outer@service.com')
      end
    end

    context 'testing nested services with call!' do
      it 'it fails on the first service so it fails the second one' do
        TestInnerFailService = Class.new(SeaFood::Service) do
          def initialize(email:)
            @email = email
          end

          def call
            fail!(email: @email)
          end
        end

        TestParentFailService = Class.new(SeaFood::Service) do
          def initialize(email:)
            @email = email
          end

          def call
            TestInnerFailService.call!(email: 'inner@service.com')
            success(email: @email)
          end
        end

        result = TestParentFailService.call(email: 'outer@service.com')
        expect(result).to be_fail
        expect(result.email).to eq('inner@service.com')
      end
    end

    context 'testing three levels nested services with call!' do
      it 'it fails on the third level service but does not cascade' do
        TestThirdFailService = Class.new(SeaFood::Service) do
          def initialize(email:)
            @email = email
          end

          def call
            fail!(email: @email)
          end
        end

        TestSecondFailService = Class.new(SeaFood::Service) do
          def initialize(email:)
            @email = email
          end

          def call
            TestInnerFailService.call!(email: 'second@service.com')
            success(email: @email)
          end
        end

        TestFirstService = Class.new(SeaFood::Service) do
          def initialize(email:)
            @email = email
          end

          def call
            TestInnerFailService.call(email: 'a')
            success(email: @email)
          end
        end

        result = TestFirstService.call(email: 'first@service.com')
        expect(result).to be_success
        expect(result.email).to eq('first@service.com')
      end
    end
  end
end
