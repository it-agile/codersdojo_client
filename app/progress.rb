class Progress

  def self.write_empty_progress states
    STDOUT.print "#{states} states to upload"
    STDOUT.print "["+" "*states+"]"
    STDOUT.print "\b"*(states+1)
    STDOUT.flush
  end

  def self.next
    STDOUT.print "."
    STDOUT.flush
  end

  def self.end
    STDOUT.puts
  end
end

