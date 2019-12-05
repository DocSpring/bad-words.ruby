require "./lib/bad_word_detector"

finder = BadWordDetector.new
puts finder.find("What the #uck")
