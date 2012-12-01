$LOAD_PATH << "#{File.expand_path(File.dirname(__FILE__))}/../lib"

require 'bad_words'

finder = BadWords.new

#string = 'Using faster code in your Ruby application is always ideal. To discover which is faster, benchmarking is necessary step. It measures the time it takes to execute code and compares it to other a##hole code that accomplishes the same task'
string = "
Is there a way to have uninterpreted strings within a YAML file? My goal is to have regular expressions that contain certain escape sequences like \w. Currently, Python's YAML complains: found unknown escape character 'w'.

I know I could escape them, but this is going to obfuscate the actual regular expression. Any way around this?
"
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