require "./processor"
#
#"#{describe Processor, 'get_library' do
#  library = ['fuck', 'dick', 'cunt']
#  it 'returns library for empty prefix' do
#    prefix = []
#    Processor.get_library(prefix, library).should eq library
#  end
#
#  it 'selects items in library that begins with first prefix key' do
#    prefix = [{:key => 'f', :length => 1}]
#    Processor.get_library(prefix, library).should eq ['fuck']
#  end
#
#  it 'select items in library that begins with prefix chars' do
#    prefix = [{:key => 'f', :length => 1}, {:key => 'u', :length => 3}, {:key => 'c', :length => 1}]
#    Processor.get_library(prefix, library).should eq ['fuck']
#  end
#end
#
#describe Processor, 'get_next_symbols' do
#  it 'returns first symbol' do
#    string = 'i am string and im ok'
#    Processor.get_next_symbols([],string).should eq [{:key => 'i',:length => 1}]
#  end
#  it 'returns nil if there no more symbols left' do
#    string = 'i am s'
#    prefix = [{:key => 'h', :length => 1}, {:key => '123', :length => 5}]
#    Processor.get_next_symbols(prefix, string).should eq nil
#  end
#  it 'returns first matching symbol translations if there are some' do
#    Processor.generate_data
#    string = 'fun and obvious'
#    string2 = '1 and obvious'
#    Processor.get_next_symbols([], string).should eq [{:key=>"f", :length=>1}]
#    Processor.get_next_symbols([], string2).should eq [{:key=>"f", :length=>1},{:key=>"i", :length=>1},{:key=>"1", :length=>1}]
#  end
#  it 'returns symbols after some prefix sequence' do
#    Processor.generate_data
#    string = 'here goes text'
#    prefix = [{:key => 'h', :length => 1}, {:key => '123', :length => 5}]
#    Processor.get_next_symbols(prefix, string).should eq [{:key => 'o', :length =>1}]
#  end
#end}"

describe Processor, 'add_to_prefix' do
  it 'appends symbols to prefix if it matches some item in library' do
    symbols = [{:key=>"f", :length=>1},{:key=>"i", :length=>1},{:key=>"1", :length=>1}]
    prefix = []
    Processor.generate_data
    Processor.add_to_prefix(symbols,prefix,Processor.library).should eq [[{:key =>'f', :length => 1}]]
  end
  it 'search symbols from index calculated as sum of prefix lengths' do
    symbols = [{:key=>"f", :length=>1},{:key=>"u", :length=>1},{:key=>"c", :length=>1}]
    prefix = [{:key=>"f", :length=>4},{:key=>"u", :length=>1}]
    Processor.generate_data
    Processor.add_to_prefix(symbols,prefix,Processor.library).should eq [[{:key=>"f", :length=>4},{:key=>"u", :length=>1},{:key=>"c", :length=>1}]]
  end
  it 'returns empty array if there are no matching sequences' do
    symbols = [{:key=>"f", :length=>1},{:key=>"u", :length=>1}]
    prefix = [{:key=>"f", :length=>4},{:key=>"u", :length=>1}]
    Processor.generate_data
    Processor.add_to_prefix(symbols,prefix,Processor.library).should eq []
  end

end
#
#describe Processor, 'get_translations' do
#  it 'returns selected char translations' do
#    Processor.generate_data
#    Processor.get_translations('f').should eq [{:key=>"f", :length=>1}]
#  end
#  it 'returns selected char translations' do
#    Processor.generate_data
#    Processor.get_translations('1').should eq [{:key=>"f", :length=>1},{:key=>"i", :length=>1},{:key=>"1", :length=>1}]
#  end
#end
#
#describe Processor, 'get_partials' do
#  it 'returns selected char partial translations' do
#    Processor.generate_data
#    Processor.get_partials('|').should eq ['|_|']
#    Processor.get_partials('p').should eq ['ph', 'pf']
#  end
#end
#
#describe Processor, 'find_partial' do
#  it 'looks for partial symbols in string, returns found str length' do
#    string = '|.._|'
#    partial = '|_|'
#    Processor.generate_data
#    Processor.find_partial(partial,string).should eq 5
#  end
#end
#
#describe Processor, 'find_partial_symbol' do
#  it 'finds symbol in string if separated by empty-convertable' do
#    string = '..._|'
#    symbol = '_'
#    Processor.generate_data
#    Processor.find_partial_symbol(symbol,string).should eq 3
#  end
#end
