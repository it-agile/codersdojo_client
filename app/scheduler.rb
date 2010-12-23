class Scheduler

  def initialize runner
    @runner = runner
  end

  def start
    @runner.start
    while true do
      sleep 1
      @runner.execute
    end
  end

end