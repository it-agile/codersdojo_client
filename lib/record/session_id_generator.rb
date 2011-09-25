require 'shellutils/date_time_formatter'

class SessionIdGenerator

  def generate_id time=Time.new
	  DateTimeFormatter.new.format time
  end

end
