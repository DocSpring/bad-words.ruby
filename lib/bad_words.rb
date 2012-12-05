require "yaml"
require "set"
require "bad_words/state"
require "bad_words/prefix_tree"
require "bad_words/rule"
require "bad_words/version"

class BadWords
  attr_reader :rule_sets,
              :string_sets,
              :library,
              :whitelist,
              :return_white

  def get_word(text, index, skip)
    word_begin = text.rindex(' ', index) || -1
    word_end = text.index(' ', (index + skip)) || text.length
    text[word_begin+1..word_end-1].gsub(/[^0-9a-z ]/i, '')
  end

  def find(string)
    time = Time.now
    string = string.downcase

    length = string.length
    thread_count = 4
    i = 0
    #trying to add multithreading. Left for the better times
    while i < length
      strings = Hash[(0..thread_count).map { |j|
        [i+j, string[i+j..-1]]
      }]
      found = strings.map do |index, input|
        found = process(input, library)
        if found
          text, length = found
          word = get_word(string, index, length)
          if check_whitelist(word)
            puts "Found good words for #{word}"
            if return_white
              {:text => input[0..length], :word => text, :index => index, :white => word, :time => Time.now - time}
            end
          else
            {:text => input[0..length], :word => text, :index => index, :time => Time.now - time}
          end
        end
      end.reject do |res|
        res.nil? or !!res[:white]
      end
      i += thread_count
      if found.any?
        return found[0]
      end
    end
    nil
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
    char_rules = rule_sets[char] || [Rule.self(char)]
    if char_rules.none? {|rule| rule.symbol == ''}
      set << Rule.empty(char)
    end

    string_rules = string_sets.select do |k,_|
      k.start_with?(char) and string.start_with?(k)
    end.values.flatten

    char_rules.concat(string_rules)
  end

  def check_whitelist(words)
    words.split(' ').all? do |word|
      whitelist.include? word
    end
  end

  def initialize(whitelist = nil)
    time = Time.now
    puts "Init rules"
    @return_white=false
    confdir = File.expand_path(File.dirname(__FILE__) + "/conf")
    yaml = YAML.load_file("#{confdir}/rules.yaml")
    @rule_sets = yaml.select do |key, _|
      key.to_s.length == 1
    end.hmap do |key, rules|
      key = key.to_s
      rules = rules.map do |item|
        Rule.new(key, item['symbol'], item['weight'])
      end
      # Self reference rule
      rules << Rule.new(key, key, 3)
      [key, rules]
    end

    @string_sets = yaml.select do |key, _|
      key.to_s.length > 1
    end.hmap do |key, rules|
      key = key.to_s
      rules = rules.map do |item|
        Rule.new(key, item['symbol'], item['weight'])
      end
      [key, rules]
    end

    puts "Init library"
    library_data = YAML.load_file("#{confdir}/library.yaml")
    @library = PrefixTree.new library_data
    puts "Init whitelist"
    @whitelist = whitelist || YAML.load_file("#{confdir}/whitelist.yaml")
    @whitelist = Set.new @whitelist
    puts "Time for init: #{Time.now - time}"
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

