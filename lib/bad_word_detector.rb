require "yaml"
require "set"
require "bad_word_detector/state"
require "bad_word_detector/prefix_tree"
require "bad_word_detector/rule"
require "bad_word_detector/version"
require "bad_word_detector/whitelist"
require "bad_word_detector/bad_word"

class BadWordDetector

  # Create new badword checker
  # 
  # @param rules [Hash<String,Array<Hash<String, any>>>] Hash where values are arrays 
  #   of Hash<['symbol', 'weight'], any> where weight is optional
  # 
  # @param library [Array<String>] Array of bad words to find
  # 
  # @param whitelist [Array<String>] Array of words that is acceptable. Used in false-positive check
  # 
  def initialize(rules = nil, library = nil,  whitelist = nil)
    confdir = File.expand_path(File.dirname(__FILE__) + "/conf")
    rules ||= YAML.load_file("#{confdir}/rules.yaml")
    library ||= YAML.load_file("#{confdir}/library.yaml")

    @rule_sets = rules.select do |key, _|
      key.to_s.length == 1
    end.hmap do |key, rule|
      key = key.to_s
      rule = rule.map do |item|
        Rule.new(key, item['symbol'], item['weight'])
      end
      rule << Rule.new(key, key, 3)
      [key, rule]
    end

    @string_sets = rules.select do |key, _|
      key.to_s.length > 1
    end.hmap do |key, rule|
      key = key.to_s
      rule = rule.map do |item|
        Rule.new(key, item['symbol'], item['weight'])
      end
      [key, rule]
    end

    @library = PrefixTree.new library
    @whitelist = Whitelist.new whitelist || YAML.load_file("#{confdir}/whitelist.yaml")
    true
  end

  #
  # Searches string for some word in library
  # 
  # @param text [String] String to search
  # 
  # @param return_white [Boolean] Flag to indicate if search should return whitelist word
  # 
  # @return [BadWord, nil] BadWord object, containing information about found word and it's position in text
  # 
  def find(text, return_white = false)
    downcased = text.downcase
    length = text.length
    index = 0
    while index < length
      found = find_part(downcased, index)
      if found 
        word = BadWord.new(
          found[:word], 
          text, 
          index, 
          found[:length], 
          @whitelist)
        if not word.white? or return_white
          return word
        end
      end
      index += 1
    end
  end

private
  def find_part(text, index)
    input = text[index..-1]
    found = unless input.start_with? ' '
      process(input, @library)
    end
    if found
      word, length = found
      {:length => length, :word => word}
    end
  end


  def process(string, library)
    plain = library[string]
    if plain && plain.value
      return plain.value, plain.value.length
    end
    passed = []
    bad_states = []
    queue = [State.new([], library)]
    until queue.empty?
      state = queue.shift
      new_states = get_new_states state, string
      if new_states
        passed << state
        success_index = new_states.index(&:success?)
        if success_index
          new_state = new_states[success_index]
          return new_state.text, new_state.length
        else
          states = (new_states - bad_states) - passed
          push_states queue, states
        end
      else
        bad_states << state
      end
    end
    nil
  end

  def push_states(queue, states)
    states.each do |state|
      weight = state.weight
      if queue.any? { |q_state| q_state == state }
        next
      end
      unless weight < 0.3
        if queue.empty? || weight < queue.last.weight
          queue << state
        elsif weight > queue.first.weight
          queue.insert(0, state)
        else
          new_index = queue.length
          queue.each_with_index do |item, index|
            if item.weight < weight
              new_index = index
            end
          end
          queue.insert(new_index, state)
        end
      end
    end
  end

  def get_new_states(state, string)
    next_symbols = get_next_symbols state.length, string
    unless next_symbols
      return nil
    end
    new_states = append_path next_symbols, state
    if new_states.empty?
      nil
    else
      new_states
    end
  end

  def append_path(symbols, state)
    symbols.map do |sym|
      state.append sym
    end.reject do |new_state|
      new_state.failure?
    end
  end

  def get_next_symbols(index, string)
    char = string[index]
    if char
      char = char.to_s
      get_rules(char, string[index..-1]) || []
    end
  end

  def get_rules(char, string)
    char_rules = @rule_sets[char] || [Rule.self(char)]
    if char_rules.none? { |rule| rule.symbol == '' }
      char_rules << Rule.empty(char)
    end

    string_rules = @string_sets.select do |k, _|
      k.start_with?(char) and string.start_with?(k)
    end.values.flatten

    char_rules.concat(string_rules)
  end

end

class Hash
  def hmap
    result = {}
    self.each do |k, v|
      k, v = yield k, v
      result[k] = v
    end
    result
  end

end
