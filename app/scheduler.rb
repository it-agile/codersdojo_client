class Scheduler

  def initialize runner
    @runner = runner
  end

  def start
		trap("INT") { 
			puts "\nYou finished your kata. Now upload it with 'codersdojo upload'."
			exit 
		}
    @runner.start
    while true do
      sleep 1
      @runner.execute
    end
  end

end