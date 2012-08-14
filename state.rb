class State

  def initialize(path, lib)
    @library = lib
    @path = path
    @text = ''
    @length = 0
    @weight = 1

    path.each do |item|
     # puts item.inspect
      @text += item[:symbol]
      @length += (item[:length] || 1)
      @weight *= (item[:weight] || (item[:symbol] == '' ? 0.3 : 1))
    end
  end

  def library
    @library
  end

  def text
    @text
  end

  def length
    @length
  end

  def weight
    @weight
  end

  def append(item)
    State.new @path + [item], State.get_library(item ? item[:symbol] : '', @library)
  end

  def failure?
    not @library
  end

  def success?
    success = @library.value
    puts @text if success
    success
  end

  def ==(sec)
    self.text == sec.text && self.length == sec.length && self.weight == sec.weight && self.library == sec.library
  end

  class <<self
    def get_library(symbol, library)
      symbol = symbol || ""
      library[symbol]
    end
  end
end