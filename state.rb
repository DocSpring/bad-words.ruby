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
    @library.empty?
  end

  def success?
    success = @library.values.index(@text)
    puts @text if success
    success
  end

  def hash
    [@path, @library].hash
  end

  class <<self
    def get_library(symbol, library)
      symbol = symbol || ""
      library.find_prefix symbol
    end
  end
end