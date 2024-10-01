# frozen_string_literal: true

RSpec.describe 'Services and form usages' do
  ######
  # Using Forms to validate data in our services
  ######

  context 'successful execution' do
    let(:user_params) do
      { email: 'fede@example.com', name: 'Fede' }
    end

    let(:address_params) do
      { line1: 'Street 1', postcode: '15005' }
    end

    it '.call - with form validations' do
      TestSucceedWithValidationsService = Class.new(SeaFood::Service) do
        def initialize(user_params:, address_params:)
          @user_params = user_params
          @address_params = address_params
        end

        def call
          user_form = UserForm.new(@user_params)
          validate_with(:user, user_form)

          AddressForm.new(@address_params)
          validate_with(:address, AddressForm.new(@address_params))

          user_form.save!

          success(user: user_form.user)
        end

        private

        def validation_pipeline
          { user: UserForm.new(@user_params), address: AddressForm.new(@address_params) }
        end
      end

      result = TestSucceedWithValidationsService.call(
        user_params: user_params,
        address_params: address_params
      )
      expect(result).to be_success
      expect(result.user.name).to eq('Fede')
    end
  end

  context 'failed execution' do
    let(:user_params) do
      { email: 'fede@example.com', name: '1111' }
    end

    let(:address_params) do
      { line1: 'Str', postcode: '15005' }
    end

    it '.call - stoping failed execution' do
      TestFailedWithValidationsService = Class.new(SeaFood::Service) do
        def initialize(user_params:, address_params:)
          @user_params = user_params
          @address_params = address_params
        end

        def call
          validate_with!(:address, AddressForm.new(@address_params))

          user_form = UserForm.new(@user_params)
          validate_with!(:user, user_form)

          user_form.save!

          success(user: user_form.user)
        end
      end

      result = TestFailedWithValidationsService.call(
        user_params: user_params,
        address_params: address_params
      )

      expect(result).to be_fail
      expect(result.errors[:address][:line1]).to eq(['is too short (minimum is 5 characters)'])
    end

    it '.call - with failed execution' do
      TestFailedWithValidationsService = Class.new(SeaFood::Service) do
        def initialize(user_params:, address_params:)
          @user_params = user_params
          @address_params = address_params
        end

        def call
          user_form = UserForm.new(@user_params)
          validate_with(:user, user_form)

          AddressForm.new(@address_params)
          validate_with(:address, AddressForm.new(@address_params))

          user_form.save!

          success(user: user_form.user)
        end
      end

      result = TestFailedWithValidationsService.call(
        user_params: user_params,
        address_params: address_params
      )
      expect(result).to be_success
    end

    it '.call - with validation pipeline' do
      TestFailedWithValidationsService = Class.new(SeaFood::Service) do
        def initialize(user_params:, address_params:)
          @user_params = user_params
          @address_params = address_params
        end

        def call
          validate_pipeline(validation_pipeline)

          user_form.save!

          success(user: user_form.user)
        end

        private

        def validation_pipeline
          { user: UserForm.new(@user_params), address: AddressForm.new(@address_params) }
        end
      end

      result = TestFailedWithValidationsService.call(
        user_params: user_params,
        address_params: address_params
      )

      expect(result).to be_fail
      expect(result.errors[:address][:line1]).to eq(['is too short (minimum is 5 characters)'])
      expect(result.errors[:user][:name]).to eq(['is invalid'])
    end
  end
end
