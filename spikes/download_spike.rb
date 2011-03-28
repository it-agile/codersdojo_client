require 'net/http'

Net::HTTP.start("www.scala-lang.org") { |http|

  open("scala.jar", "wb") { |file|
  	resp = http.request_get("/downloads/distrib/files/scala-2.8.1.final-installer.jar") {|res|
			seg_count = 0
			res.read_body do |segment|
				seg_count += 1
				if seg_count > 100
		    	STDOUT.print "."
		    	STDOUT.flush
					seg_count = 0
				end
    		file.write(segment)
			end
		}
	}

#resp = http.get("/downloads/distrib/files/scala-2.8.1.final-installer.jar")
#  open("scala.jar", "wb") { |file|
#    file.write(resp.body)
#   }
}
puts "Yay!!"
