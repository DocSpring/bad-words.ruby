class Rule
  getter :symbol,
          :char,
          :size,
          :weight
  
  @length : Int32 

  def initialize(char : String, symbol : String, weight : Int32 | Nil = nil)
    @char = char
    @symbol = symbol
    @weight = weight || 2
    @length = char.size
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

  # class << self
  def self.self(char)
    self.new(char, char, 3)
  end

  def self.empty(char)
    self.new(char, "", 0.2)
  end
  # end
end
