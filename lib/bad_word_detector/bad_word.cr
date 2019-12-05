class BadWord
  attr_reader :text, :word, :index, :source, :white_words

  #
  # Create new BadWord
  #
  # @param word [String] found word
  # @param source [String] Source text where word was found
  # @param index [Integer] index of word in source
  # @param length [Integer] word length
  # @param whitelist [Array<String>] Whitelist words
  def initialize(word, source, index, size, whitelist)
    @index = index
    @length = size
    @word = word
    @source = source
    word_end = @index + @length - 1
    space_location = @source.index(" ", word_end) || 0
    @text = @source[@index..space_location - 1]
    @white_words = whitelist.check_bad_word(self)
  end

  #
  # Check if word is in whitelist
  # @return [true, false]
  def white?
    !!@white_words
  end
end
