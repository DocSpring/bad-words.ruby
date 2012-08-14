require './bad_words'

finder = BadWords.new
finder.find 'fuck'

string = 'Using faster code in your Ruby application is always ideal. To discover which is faster, benchmarking is necessary step. It measures the time it takes to execute code and compares it to other code that accomplishes the same task'

finder.find string

#require 'ruby-prof'
#
## Profile the code
#RubyProf.start
#
#BadWords.find string
#
#result = RubyProf.stop
#
## Print a flat profile to text
#printer = RubyProf::FlatPrinter.new(result)
#printer.print(STDOUT)