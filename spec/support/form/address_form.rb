class AddressForm < SeaFood::Form
  attr_accessor :line1, :postcode

  validates :line1, length: { minimum: 5 }

  def initialize(args)
    super(args)

    @model = address
  end

  def address
    @address ||= Address.new(line1: line1, postcode: postcode)
  end
end
