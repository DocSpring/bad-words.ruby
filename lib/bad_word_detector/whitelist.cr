class Whitelist
  def initialize(list)
    @words_set = Set.new list
  end

  def check_substring(text, index, size)
    words = text.get_substring_words(index, size)
    self.check(words)
  end

  def check(words)
    all_white = words.all? do |word|
      @words_set.includes? word
    end
    if all_white
      words
    end
  end

  def check_bad_word(word)
    self.check_substring(word.source, word.index, word.word.size)
  end

  def inspect
    "#<#{self.class.name}:#{self.object_id}>"
  end
end

class String
  def get_substring_words(index, size)
    word_begin = self.rindex(" ", index) || -1
    word_end = self.index(" ", (index + size)) || self.size
    self[word_begin + 1..word_end - 1].split(/[[:punct:]\s]+/)
  end
end
