alias HashTree = Hash(Symbol | String | Char, Symbol | Char | String | Hash(Symbol | Char | String, HashTree))

class PrefixTree
  @hash_tree : HashTree

  def inspect
    "#<#{self.class.name}:#{self.object_id}>"
  end

  def initialize(items = [] of String, hash_tree : HashTree = {} of Symbol | String | Char => Symbol | Char | String | Hash(Symbol | Char | String, HashTree))
    @hash_tree = hash_tree.clone
    unless items.empty?
      items.each do |i|
        self << i
      end
    end
  end

  def hash_tree
    @hash_tree
  end

  def <<(string)
    parts = string.chars
    new_hash = self.hash_tree
    parts.each do |part|
      unless new_hash[part]
        new_hash[part] = {} of Symbol | String | Char => Symbol | Char | String | Hash(Symbol | Char | String, HashTree)
      end
      new_hash = new_hash[part]
    end
    new_hash[:value] = string
    self
  end

  def [](string = "")
    parts = string.chars
    new_hash = self.hash_tree
    parts.each do |part|
      unless new_hash[part]
        return nil
      end
      new_hash = new_hash[part]
    end
    PrefixTree.new [] of String, new_hash
  end

  def value
    self.hash_tree[:value]
  end

  def children?(string)
    (self[string].hash_tree.keys - [:values]).any?
  end

  def clone
    PrefixTree.new([] of String, hash_tree)
  end

  def ==(sec)
    sec.hash_tree == self.hash_tree
  end
end
