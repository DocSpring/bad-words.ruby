require "./processor"

BadWords.generate_data

puts BadWords.find(ARGV[0])