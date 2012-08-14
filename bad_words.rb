require "yaml"
require "./state"
require "./prefix_tree"

class BadWords
  attr_accessor :return_white, :translations, :partials, :library, :whitelist

  def deep
    5
  end

  def get_word(text, index, skip)
    word_begin = text.rindex(' ', index) || 0
    word_end = text.index(' ', (index + skip)) || text.length
    text[word_begin+1..word_end-1].gsub(/[^0-9a-z ]/i, '')
  end

  def find(string)
    time = Time.now
    string = string.downcase
    (0..string.length).each do |i|
      # puts string[i..-1]
      input = string[i..-1]
      found = process(input, library)
      if found
        puts "#{Time.now - time}"
        text, length = found
        puts "Found bad combination #{input[0..length]} looks like #{text}"

        word = get_word(string, i, length)
        puts word
        if check_whitelist(word)
          puts "Found good words for #{word}"
          if return_white
            {:text => input[0..length], :word => text, :index => i, :white => word}
          end
        else
          {:text => input[0..length], :word => text, :index => i}
        end
      end
    end
    puts "#{Time.now - time}"
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
        new_states.each do |new_state|
          if new_state.success?
            return new_state.text, new_state.length
          end
        end
        #puts 'good' + new_states.map(&:text).inspect
        #puts 'bad' + bad_states.map(&:text).inspect
        states = (new_states - bad_states) - passed
        push_states queue, states
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
      new_state = state.append sym
    end.reject do |state|
      state.failure?
    end
  end

  def get_next_symbols(index, string)
    char = string[index]
    if char
      char = char.to_s
      translations = get_translations(char) || []
      partials = get_partials(char) || []
      translations + (partials.map do |partial|
        length = find_partial(partial, string[index..-1])
        if length
          get_translations(partial).map do |translation|
            translation.merge :length => length
          end
        end
      end.reject(&:nil?).inject([]) do |sum, tr|
        sum + tr
      end)
    end
  end

  def find_partial(partial, string)
    index = 0
    partial[1..-1].split(//).all? do |part|
      search_in = string[index..deep]
      new_index = find_partial_symbol(part, search_in)
      unless new_index
        return nil
      end
      index += new_index
    end
    index+1
  end

  def find_partial_symbol(symbol, chars)
    chars.split(//).each_with_index do |char, index|
      translations = get_translations(char)
      translations.each do |translation|
        if translation[:symbol] == symbol
          return index
        end
      end
    end
    nil
  end

  def get_translations(char)
    tr = (translations[char] || (char.length == 1 ? [{:symbol => char, :length => 1, :weight => 3, :char => char}] : []))
    if tr.none? { |item| item[:symbol] == '' }
      tr << {:symbol => '', :length => 1, :weight => 0.2, :char => char}
    end
    tr
  end

  def get_partials(char)
    partials.select do |key, _|
      key.start_with? char
    end.map do |key, _|
      key
    end
  end

  def collapsable?(symbol)
    get_translations(symbol[:key]).any? do |tr|
      tr[:key].empty?
    end
  end

  def check_whitelist(words)
    words.split(' ').all? do |word|
      whitelist.index word
    end
  end

  def initialize
    self.return_white=false

    yaml = YAML.load_file("rules.yaml")
    self.translations = Hash[yaml.map do |key, rule|
      key = key.to_s
      rule = rule.concat([{"symbol" => key, "weight" => 3}]).map do |item|
        {:symbol => item['symbol'], :weight => item['weight'], :length => 1, :char => key}
      end
      [key, rule]
    end]
    self.partials = Hash[yaml.select do |key, _|
      key.to_s.length > 1
    end.map do |key, rule|
      key = key.to_s
      rule = rule.map do |item|
        {:symbol => item['symbol'], :weight => item['weight'], :length => 1, :char => key}
      end
      [key, rule]
    end]

    library_data = YAML.load_file('library.yaml')
    self.library = PrefixTree.new library_data
    self.whitelist = YAML.load_file('whitelist.yaml')
  end
end

