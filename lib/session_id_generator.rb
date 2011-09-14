class SessionIdGenerator

  def generate_id time=Time.new
		year = format_to_length time.year, 4
		month = format_to_length time.month, 2
		day = format_to_length time.day, 2
		hour = format_to_length time.hour, 2
		minute = format_to_length time.min, 2
		second = format_to_length time.sec, 2
    "#{year}-#{month}-#{day}_#{hour}-#{minute}-#{second}"
  end

  def format_to_length value, len
		value.to_s.rjust len,"0"
	end

end
