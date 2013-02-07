require "csv"
require_relative 'phone'
require_relative 'zipcode'

Attendee = Struct.new(:first_name, :last_name, :email_address, :homephone, :street, :city, :state, :zipcode)

class EventAttendee
  
  def initialize(filename)
    @filename = filename
  end

  def get_attendees
    #data = []
    contents = CSV.open "data/#{@filename}", headers: true, header_converters: :symbol    

    # contents.each do |person|
    #   person_hash = {}
    #   person_hash["first_name"] = person[:first_name].to_s
    #   person_hash["last_name"] = person[:last_name].to_s
    #   person_hash["email_address"] = person[:email_address].to_s
    #   person_hash["homephone"] = Phone.new(person[:homephone].to_s).clean_phone_number
    #   person_hash["street"] = person[:street].to_s
    #   person_hash["city"] = person[:city].to_s
    #   person_hash["state"] = person[:state].to_s
    #   person_hash["zipcode"] = Zipcode.new(person[:zipcode].to_s).clean_zipcode
    #   data.push(person_hash)
    # end
    # data 

    contents.each_with_object([]) do |person, data|
      first_name = person[:first_name].to_s
      last_name = person[:last_name].to_s
      email_address = person[:email_address].to_s
      homephone = Phone.new(person[:homephone].to_s).clean_phone_number
      street = person[:street].to_s
      city = person[:city].to_s
      state = person[:state].to_s
      zipcode = Zipcode.new(person[:zipcode].to_s).clean_zipcode
      attendee = Attendee.new(first_name, last_name, email_address, homephone, street, city, state, zipcode)
      data.push(attendee)
    end
  end

  # def find(attribute, criteria)
  #   attribute = attribute.to_sym
  #   results = list.select {|person| person[attribute].downcase == criteria }
  # end
end