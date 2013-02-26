class Whitelist

  def initialize(list)
    @words_set = Set.new list
  end
  def check_substring(text, index, length)
    words = text.get_substring_words(index, length)
    self.check(words)
  end

  def check(words)
    all_white = words.all? do |word|
      @words_set.include? word
    end
    if all_white 
      words
    end
  end

  def check_bad_word(word)
    self.check_substring(word.source, word.index, word.word.length)
  end

end


class String
  def get_substring_words(index, length)
    word_begin = self.rindex(' ', index) || -1
    word_end = self.index(' ', (index + length)) || self.length
    self[word_begin+1..word_end-1].split(/[[:punct:]\s]+/)
  end
end