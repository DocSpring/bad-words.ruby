require './bad_words'

BadWords.find 'fuck'

string = 'Using faster code in your Ruby application is always ideal. To discover which is faster, benchmarking is necessary step. It measures the time it takes to execute code and compares it to other code that accomplishes the same task'

BadWords.find string

require 'ruby-prof'

# Profile the code
RubyProf.start

BadWords.find string

result = RubyProf.stop

# Print a flat profile to text
printer = RubyProf::FlatPrinter.new(result)
printer.print(STDOUT)