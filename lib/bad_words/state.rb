class State
  attr_reader :library, :text, :length, :weight

  def initialize(path, lib)
    @library = lib
    @path = path
    @text = ''
    @length = 0
    @weight = 1

    path.each do |rule|
     # puts item.inspect
      @text += rule.symbol
      @length += rule.length
      @weight *= rule.weight
    end
  end

  def append(rule)
    State.new @path + [rule], State.get_library(rule ? rule.symbol : '', @library)
  end

  def failure?
    not @library
  end

  def success?
    @library.value
  end

  def ==(sec)
    self.text == sec.text && self.length == sec.length && self.weight == sec.weight && self.library == sec.library
  end

  class << self
    def get_library(symbol, library)
      symbol = symbol || ""
      library[symbol]
    end
  end
end