class Address < ActiveRecord::Base
  validates :line1, presence: true
  validates :postcode, presence: true

  def custom_validation
    'A validation method used in the specs'
  end
end
