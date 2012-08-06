require './processor'
BadWords.generate_data
BadWords.find 'fuck'

require 'ruby-prof'

# Profile the code
RubyProf.start

BadWords.find 'fuck'

result = RubyProf.stop

# Print a flat profile to text
printer = RubyProf::FlatPrinter.new(result)
printer.print(STDOUT)