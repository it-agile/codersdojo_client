class Scheduler

  attr_accessor :interrupt_listener

  def initialize runner
    @runner = runner
  end

  def start
	  @continue = true
		register_interrupt_listener
    @runner.start
    while @continue do
      sleep 1
      @runner.execute
    end
  end

private

	def register_interrupt_listener
		trap("INT") {
			interrupt
		}
	end
	
	def interrupt
		if @interrupt_listener then @continue = @interrupt_listener.interrupt end
  end

end