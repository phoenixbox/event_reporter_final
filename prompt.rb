require_relative 'event_attendee'

class Prompt

# <--------------------------------------- Help Command Strings --------------------------------------->

  COMMANDS = {"load <filename>" => "Erase any loaded data and parse the specified file. If no filename is given, default to event_attendees.csv", 
                 "help" => "Output a list of the available individual commands",
                 "help <command>" => "Output a description of how to use the specific command",
                 "queue count" => "Output how many records are in the current queue",
                 "queue clear" => "Empty the queue",
                 "queue print" => "Print out a tab-delimited data table with a header row",
                 "queue print by <attribute>" => "Print the data table sorted by the specified attribute like zipcode",
                 "queue save to <filename.csv>" => "Export the current queue to the specified filename as a CSV",
                 "queue <attribute> <criteria>" => "Load the queue with all records matching the criteria for the given attribute",
                 "quit" => "Quit the EventReporter program"}

# <------------------------------------ Table Headers & Gutters --------------------------------------->

  FIELDS = ["First_name", "Last_name", "Email_address", "Homephone", "Street", "City", "State", "Zipcode"]

  GUTTER = 10

# <--------------------------------Instatiate Object & Ask For User Inuput -------------------------------->

  def initialize
    @data = []
    @queue = []
  end

  def run
    welcome
    command = ""
    while command != "quit"
      printf "Enter Command: "
      input = gets.chomp
      parts = input.split(" ")
      command = parts[0]
      options = parts[1..-1]

      command_controller(command, options)
    end
  end

  def welcome
    welcome_format
    puts "<-------------------- Welcome to the Event Reporter -------------------->"
    welcome_format
  end

  def welcome_format
    puts "-"*75
  end

# <-------------------------------- Pass Input to Command Controller -------------------------------->

  def command_controller(command, options)
    case command
     when "load" then load_command(options)
     when "help" then help_command(options)
     when "find" then find_command(options)
     when "queue" then queue_command(options)
     when "quit" then shutdown
     else
      puts sorry
    end
  end

# <-------------------------------- Command Methods -------------------------------->

  def load_command(options)
    if options[0].to_s == ""
      load_file("event_attendees.csv")
      puts "You didnt specify a CSV file to load so we just loaded the event_attendees.csv file for you"
    else
      load_file(options[0..-1].join)
    end
  end

  def help_command(options)
    args = options[0..-1]
      if args.empty?
        puts "Called help method WITHOUT arguments passed"
        help
      else
        puts "Called help method WITH arguments passed"
        args.join(" ")
        help(args)
      end
    end

  def find_command(options)
      args = options[0..-1]
      if @data.empty?
        puts "You need to load a CSV file before you use the find command"
      elsif args.empty?
        puts "Please add an attribute and criteria after your find request"
      else
        args = options[0..-1].join(" ")
        find(args)
      end
  end

  # def queue_command(options)
  #   args = options[0..-1]
  #   puts "im in"
  #   case args
  #     when args.empty? then sorry
  #     when args[0] == 'count' then queue_count
  #     when args[0] == 'clear' then queue_clear
  #     when args[0] == 'print' && args[1] != "by" then queue_print
  #     when args[0] == 'print' && args[1] == "by" then sort_queue(args[2])
  #     when args[0] == 'save' && args[1] == 'to' then queue_save(args[2])
  #     else
  #       puts puts "Sorry: please add either count/clear/print(by) or save, as additional argument to queue"
  #     end
  # end
      
  def queue_command(options)
    args = options[0..-1]
      if args.empty?
        puts sorry
      elsif args[0] == 'count'
        queue_count
      elsif args[0] == 'clear'
        queue_clear
      elsif args[0] == 'print' && args[1] != "by"
        queue_print
      elsif args[0] == 'print' && args[1] == "by"
        sort_queue(args[2])
      elsif args[0] == 'save' && args[1] == 'to'
        queue_save(args[2])
      else
        puts "Sorry: please add either count/clear/print(by) or save, as additional argument to queue"
      end
  end

  def shutdown
    puts "Shutting down Event Reporter"
  end

  def sorry
    puts "Sorry that command is not supported, type help for a list of supported commands"
  end


# <-------------------------------- Load Support Method -------------------------------->


  def load_file(filename)
    @data = EventAttendee.new(filename).get_attendees
    puts "You have loaded #{filename}" + "\n"
    puts "There were #{@data.length} records loaded from #{filename}"
  end

# <-------------------------------- Help Support Methods -------------------------------->

  def print_commands(command_hash)
    dash_line
    print "COMMAND".ljust(40) + "DESCRIPTION".ljust(15) + "\n"
    dash_line
    command_hash.each do |command, description|
      print command.ljust(40) + description.ljust(15) + "\n"
    end
    dash_line
  end

  def help(*option)
    if option.empty?
      print_commands(COMMANDS)
    else
      command = option[0..-1].join(" ")
      if COMMANDS.include?(command)
        new_hash = Hash.new
        new_hash[command] = COMMANDS[command]
        print_commands(new_hash)
      else
        puts sorry
      end
    end
  end

# <-------------------------------- Find Support Methods -------------------------------->

  def find(args)
    @queue = []
    array = args.split
    search(array[0], array[1..-1].join(" "))
  end

  def search(attribute, criteria)
    @queue = @data.select {|person| person[attribute.to_sym].downcase == criteria.downcase}
    puts "#{@queue.size} records found"
  end

# <<<------------------------------ Formatting Methods ------------------------------>>>

  def dash_line
    puts "-"*170
  end

# <<<------------------------------ Table Commands ------------------------------>>>
  
  def get_column_widths(fields)
    fields_widths_hash = {}
    fields.each do |field|
      fields_widths_hash[field.downcase] = get_longest_value(field.downcase)
    end
    fields_widths_hash
  end

  def get_longest_value(field)
    array = []
    @queue.each do |person|
      array << person[field].length
    end
    array.max
  end

#  <<<-------------------------- Queue Support Methods ------------------------->>>

  def queue_count
    puts "The number of records in the queue is currently: #{@queue.size}"
  end

  def queue_clear
    if @queue.empty?
      puts "The queue is empty so there is nothing to clear"
    else
      puts "We are now clearing the queue for you..." + "\n"
      @queue = []
      puts "The queue has been successfully cleared! The next time you perform a query it will be added to the queue"
    end
  end

   def queue_print
      if @queue.empty?
        puts "The queue is empty so there is nothing to print"
      else
      print_queue
    end
  end

  def print_results_header(field_widths)
   puts ""
   dash_line
   print "LAST NAME".ljust(field_widths["last_name"] + GUTTER) + "FIRST NAME".ljust(field_widths["first_name"] + GUTTER) + "EMAIL".ljust(field_widths["email_address"] + GUTTER) + 
          "ZIPCODE".ljust(field_widths["zipcode"] + GUTTER) + "CITY".ljust(field_widths["city"] + GUTTER) + "STATE".ljust(field_widths["state"] + GUTTER) + "ADDRESS".ljust(field_widths["street"] + GUTTER) + 
          "PHONE".ljust(field_widths["homephone"]) + "\n"
   dash_line
   puts "\n"
  end

  def print_queue
    field_widths = get_column_widths(FIELDS)
    print_results_header(field_widths)
    count = 0
    q_size = @queue.size
    @queue.each do |person|
      if (count != 0) && (count % 10 == 0)
        puts "Displaying records #{count - 10} - #{count} of #{q_size}"
        input = ""
        while input != "\n" #|| input != "\n"
          puts "press space bar or the enter key to show the next set of records"
          input = gets
        end
      end
      print person[:last_name].ljust(field_widths["last_name"] + GUTTER) + person[:first_name].ljust(field_widths["first_name"] + GUTTER) + person[:email_address].ljust(field_widths["email_address"] + GUTTER) + 
            person[:zipcode].ljust(field_widths["zipcode"] + GUTTER) + person[:city].ljust(field_widths["city"] + GUTTER) + person[:state].ljust(field_widths["state"] + GUTTER) + 
            person[:street].ljust(field_widths["street"] + GUTTER) + person[:homephone].ljust(field_widths["homephone"]) + "\n" 
      count += 1
    end
  end
end

  def get_longest_value(field)
    array = []
    @queue.each do |person|
      array << person[field].length
    end
    array.max
  end

  # pass the header title attribute to sort by it
  def sort_queue(attribute)
    puts "Just about to sort the queue"
    @queue = @queue.sort_by do |person|
      person[attribute.to_sym].downcase
    end
    queue_print
  end

  def queue_save(filename)
    header_row = ["First_name", "Last_name", "Email_address", "Homephone", "Street", "City", "State", "Zipcode"]

    puts "Just about to save the queue records to a csv file!"
    Dir.mkdir("data") unless Dir.exists?("data")
    CSV.open("data/#{filename}", "w") do |csv|
      csv << header_row
      @queue.each do |person|
        csv << [person[:first_name], person[:last_name], person[:email_address], person[:zipcode], person[:city], person[:state], person[:street], person[:homephone]]
      end
    end
  end




