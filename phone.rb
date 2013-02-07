class Phone

  def initialize(phone_number)
    @phone_number = phone_number
  end

  def clean_phone_number
    @phone_number.gsub!(/[^0-9]/, "")
    if @phone_number.length == 11
      if @phone_number[0] == 1
        @phone_number[1..-1]
      else 
        @phone_number = "X"*10
      end
    elsif @phone_number.length == 10
      @phone_number
    else
      @phone_number = "X"*10
    end
  end

end