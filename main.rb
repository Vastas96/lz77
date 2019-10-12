require 'pry'
require 'optparse'
require './lz77.rb'

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: main.rb [options] <file>"

  opts.on("-m", "--mode MODE", [:encode, :decode], "Set the mode: encode/decode") do |m|
    options['mode'] = m
  end

  opts.on("-w", "--window LENGTH", "Set the window size") do |m|
    options['window'] = m
  end

  opts.on("-l", "--length LENGTH", "Set the word length") do |m|
    options['length'] = m
  end
end.parse!

if options['mode'].nil?
  puts "You must specify a mode: encode/decode"
  Kernel::exit(FALSE)
end

if ARGV.length < 1
    puts "You must specify some file to #{options['mode']}"
end

options['window'] = 11 if options['window'].nil?
options['length'] = 4 if options['length'].nil?

case options['mode']
  when :encode
    LZ77.new.encode_file(ARGV.first, options['window'].to_i, options['length'].to_i)
  when :decode
    LZ77.new.decode_file(ARGV.first)
  else
    puts "Invalid mode"
    Kernel::exit(FALSE)
end
