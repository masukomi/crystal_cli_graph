require "./crystal_cli_graph/*"

module CrystalCliGraph
  KEY_CHARS = ("a".."z").to_a + ("A".."Z").to_a

  def self.calculate_max_key_chars(data : Array(Int32), key_chars : Array(String))
    (data.size / key_chars.size) + 1
  end

  def self.get_key_chars(custom_chars : Array(String)?) : Array(String)
    if ! custom_chars.nil?
      cc = custom_chars.as(Array(String))
      if ! cc.empty?
        cc
      else
        KEY_CHARS
      end
    else
      KEY_CHARS
    end
  end

  def self.generate_key_for_index(idx : Int32, max_key_chars : Int32,
                                  key_chars : Array(String)) : String
    multiplier = (idx / key_chars.size) + 1
    lc_idx = idx - (multiplier * key_chars.size)
    key = (key_chars[lc_idx] * multiplier)
    if key.size < max_key_chars
      key_padding_size = max_key_chars - key.size
      key += (" " * key_padding_size)
    end
    key
  end
end
