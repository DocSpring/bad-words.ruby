class State
  getter :library, :text, :size, :weight

  def initialize(path, library)
    @library = library
    @path = path
    @text = ""
    @length = 0
    @weight = 1

    path.each_index do |index|
      # puts item.inspect
      rule = path[index]
      @text += rule.symbol
      @length += rule.size
      @weight *= rule.weight
    end
  end

  def append(rule)
    last_char_index = @path.rindex { |r| r.symbol != "" }
    rule = if last_char_index && @path[last_char_index].symbol == rule.symbol && rule.symbol != ""
             Rule.new rule.char, "", 1
           else
             rule
           end
    State.new @path + [rule], State.get_library(rule ? rule.symbol : "", @library)
  end

  def failure?
    !@library
  end

  def success?
    @library.value
  end

  def ==(sec)
    self.text == sec.text && self.size == sec.size && self.weight == sec.weight && self.library == sec.library
  end

  # class << self
  def self.get_library(symbol, library)
    symbol = symbol || ""
    library[symbol]
  end
  # end
end
