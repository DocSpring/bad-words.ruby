class Rule
  attr_reader :symbol,
              :char,
              :length,
              :weight

  def initialize(char, symbol, weight = nil)
    @char = char
    @symbol = symbol
    @weight = weight || 2
    @length = char.length
  end

  def merge(hash)
    new_hash = hash.hmap do |k, v|
      [k.to_s, v]
    end
    self.class.new(
        new_hash[:char] || self.char,
        new_hash[:symbol] || self.symbol,
        new_hash[:weight] || self.weight,
    )
  end

  class << self
    def self(char)
      self.new(char, char, 3)
    end
    def empty(char)
      self.new(char, '', 0.2)
    end
  end


end