$LOAD_PATH << "#{File.expand_path(File.dirname(__FILE__))}/../lib"

require 'bad_word_detector'
require "yaml"
require "test/unit"

class TestBadWordDetector < Test::Unit::TestCase
  def finder 
    Finder::finder
  end
  def test_word
    word = finder.find("fuck")
    assert_not_nil word
    assert_equal "fuck", word.text 
    assert_equal "fuck", word.word
    assert_equal "fuck", word.source
    assert_equal 0, word.index 
  end
  def test_word_in_text
    word = finder.find("What the fuck is going on?")
    assert_not_nil word
    assert_equal "fuck", word.text 
    assert_equal "fuck", word.word
    assert_equal "What the fuck is going on?", word.source
    assert_equal 9, word.index 
  end
  def test_with_distortion
    word = finder.find('#|_|ck')
    assert_not_nil word
    assert_equal "#|_|ck", word.text 
    assert_equal "fuck", word.word
    assert_equal "#|_|ck", word.source
    assert_equal 0, word.index 
  end
  def test_with_distortion_in_text
    word = finder.find('What the #uk is going on?')
    assert_not_nil word
    assert_equal "fuck", word.word
    assert_equal '#uk', word.text 
    assert_equal 'What the #uk is going on?', word.source
    assert_equal 9, word.index 
  end
  def test_distortion
    word = finder.find('What the #$@# is going on?')
    assert_nil word
  end
  def test_spaces
    word = finder.find('What the f_..__u_..__c_..__k is going on?')
    assert_not_nil word
    assert_equal "f_..__u_..__c_..__k", word.text 
    assert_equal "fuck", word.word
    assert_equal "What the f_..__u_..__c_..__k is going on?", word.source
    assert_equal 9, word.index 
  end
  def test_false_positive
    word = finder.find("tuck", true)
    assert_not_nil word
    assert_equal true, word.white?
  end
  def test_false_positive_in_text
    word = finder.find("Thing as is!", true)
    assert_not_nil word
    assert_equal true, word.white?
    assert_equal "ass", word.word
  end
end

class Finder
  def self.finder
    @finder ||= BadWordDetector.new YAML.load_file(File.dirname(__FILE__)+"/rules.yaml")
  end
end