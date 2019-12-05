$LOAD_PATH << "#{File.expand_path(File.dirname(__FILE__))}/../lib"

require "bad_word_detector"

finder = BadWordDetector.new

#string = 'Using faster code in your Ruby application is always ideal. To discover which is faster, benchmarking is necessary step. It measures the time it takes to execute code and compares it to other a##hole code that accomplishes the same task'
string = "tuck"
time = Time.now
found = finder.find string
puts "Time to find: #{Time.now - time}"
puts found.inspect
#
#require 'ruby-prof'
#
## Profile the code
#RubyProf.start
#
#finder.find string
#
#result = RubyProf.stop
#
## Print a flat profile to text
#printer = RubyProf::CallStackPrinter.new(result)
##printer = RubyProf::FlatPrinter.new(result)
#printer.print(File.open("report.html", "w"))
