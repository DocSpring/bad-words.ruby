require "yaml"
require "json"
require "trie"
require "./state"

class BadWords
  class << self
    @translations = {}
    @partials = {}
    @library = []

    def deep
      5
    end

    def find(string)
      time = Time.now
      string = string.downcase
      (0..string.length).each do |i|
        # puts string[i..-1]
        if process(string[i..-1], library)
          puts "#{Time.now - time}"
          return true
        end
      end
      false
    end

    def process(string, library)
      unless library.find(string).values.empty?
        puts string
        return true
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
              return true
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
      false
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
        new_state unless new_state.library.empty?
      end.reject(&:nil?)
    end

    def get_next_symbols(index, string)
      char = string[index]
      if char
        translations = get_translations(char) || []
        partials = get_partials(char) || []

        translations + (partials.map do |partial|
          length = find_partial(partial, string[index..-1])
          if length
            get_translations(partial).map do |translation|
              translation[:length] = length
              translation
            end
          end
        end.reject(&:nil?).inject([]) do |sum, translations|
          sum + translations
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
      tr = (translations[char] || (char.length == 1 ? [{:symbol => char, :length => 1, :weight => 5, :char => char}] : nil)).clone
      if tr.none? { |item| item[:symbol] == '' }
        tr << {:symbol => '', :length => 1, :weight => 0.3, :char => char}
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

    def generate_data
      yaml = YAML.load_file("rules.yaml")
      @translations = Hash[yaml.map do |key, rule|
        key = key.to_s
        rule = rule.concat([{"symbol" => key, "weight" => 3}]).map do |item|
          {:symbol => item['symbol'], :weight => item['weight'], :length => 1, :char => key}
        end
        [key, rule]
      end]
      @partials = Hash[yaml.select do |key, _|
        key.to_s.length > 1
      end.map do |key, rule|
        key = key.to_s
        rule = rule.map do |item|
          {:symbol => item['symbol'], :weight => item['weight'], :length => 1, :char => key}
        end
        [key, rule]
      end]
      library_data = JSON.parse(File.read('library.json'))["words"] # YAML.load_file 'library.yaml'
      @library = Trie.new
      library_data.each do |item|
        @library.insert item, item
      end
    end

    def translations
      @translations || {}
    end

    def partials
      @partials || {}
    end

    def library
      @library || {}
    end
  end
end
