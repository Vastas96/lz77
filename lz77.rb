require 'pry'
require 'active_support/all'
require 'yaml'

class LZ77
  attr_reader :result, :text, :window_size, :length_size

  def encode_file(file_path, window_size, length_size)
    @window_size = window_size
    @length_size = length_size

    text_file = File.open(file_path)

    text = text_file.read(text_file.size)

    encoded_text = encode(text).join

    remainder = (8 - (17 + encoded_text.size) % 8) % 8

    encoded_file_name = file_path + '.lz77'

    File.open(encoded_file_name, 'wb' ) { |f| f.write [remainder.to_s(2).rjust(3, '0') + window_size.to_s(2).rjust(7, '0') + length_size.to_s(2).rjust(7, '0') + encoded_text].pack('B*') }
  end

  def decode_file(file_path)
    text_file = File.open(file_path)

    encoded_text = text_file.read(text_file.size).unpack('B*').join

    remainder = encoded_text[0...3].to_i(2)
    @window_size = encoded_text[3...10].to_i(2)
    @length_size = encoded_text[10...17].to_i(2)

    encoded_text = encoded_text[17..(-1 - remainder)]

    original_text = decode(encoded_text)

    File.open(file_path + '.ori', 'wb' ) { |f| f.write original_text }
  end

  def longest_match(position)
    i = (1 + window_size + length_size) / 8

    window = text[0...position].last(2.pow(window_size))

    while window.index(text[position..position + i]) != nil && i < window.size && i < 2.pow(length_size) && position + i < text.size
      i += 1
    end

    i -= 1

    {length: i, offset: window.index(text[position..position + i]), word: text[position..position + i]}
  end

  def encode(text)
    @result = []
    @text = text
    i = 0

    while i < text.size
      prefix = longest_match(i)

      if prefix[:length] > 2
        result << ['1' + prefix[:offset].to_s(2).rjust(window_size, '0') + prefix[:length].to_s(2).rjust(length_size, '0')]
        i += prefix[:length] + 1
      else
        result << ['0' + text[i].ord.to_s(2).rjust(8, '0')]
        i += 1
      end
    end

    result
  end


  def decode(text)
    @result = ''
    i = 0

    while i < text.size
      if text[i] == '1'
        i += 1
        offset = text[i...(i + window_size)].to_i(2)
        length = text[(i + window_size)...(i + window_size + length_size)].to_i(2)

        @result.last(2.pow(window_size))[offset..(offset + length)].each_byte do |c|
          @result << c.chr
        end
        i += window_size + length_size
      else
        i += 1
        @result += [text[i...(i + 8)]].pack('B*')
        i += 8
      end
    end

    result
  end
end
