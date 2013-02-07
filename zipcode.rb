class Zipcode
  attr_accessor :zipcode
  
  def initialize(zipcode)
    @zipcode = zipcode
  end


  def clean_zipcode
    @zipcode.to_s.rjust(5, '0')[0,5]
  end
end