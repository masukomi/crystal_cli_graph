module CrystalCliGraph
  class Legend
    getter :max_width
    getter :labels
    getter :data

    # Warning: assumes there will be a space between each word.
    #          This is not a valid assumption for all languages
    def initialize(
                   @data : Array(Int32),
                   @labels : Array(String),
                   @key_chars : Array(String),
                   @max_width : Int32)
    end

    def generate : String
      max_key_chars = CrystalCliGraph.calculate_max_key_chars(data, CrystalCliGraph::KEY_CHARS)
      left_cols_size = 2 + max_key_chars + 2
      # ^^ that's  "| " + max_key_chars + ": "
      right_cols_size = 2
      # ^^ that's " |"

      rows_wo_edges = Array(String).new
      max_text_width = max_width - left_cols_size - right_cols_size
      data.each_with_index do |ignore, idx|
        key = CrystalCliGraph.generate_key_for_index(idx, max_key_chars, CrystalCliGraph::KEY_CHARS)
        rows_wo_edges += generate_legend_row(labels[idx], key, max_width,
          max_key_chars)
      end
      max_legend_width = rows_wo_edges.map { |r| r.size }.max
      if max_legend_width + 4 < max_width
        max_legend_width = max_width - 4
      end
      response = String.build do |str|
        # now pad the right edge
        str << generate_horizantal_edge(max_legend_width + 4)
        str << "\n"
        rows_wo_edges = pad_rows_to_width(rows_wo_edges,
          max_legend_width)

        rows_wo_edges.each do |row|
          str << "| "
          str << row
          str << " |\n"
        end

        str << generate_horizantal_edge(max_legend_width + 4)
      end
    end

    def pad_rows_to_width(rows : Array(String), largest_legend_size : Int32) : Array(String)
      new_rows = Array(String).new
      rows.each do |row|
        new_rows.push(String.build do |str|
          str << row
          if row.size < largest_legend_size
            # padding
            str << (" " * (largest_legend_size - row.size))
          end
        end)
      end
      new_rows
    end

    def generate_horizantal_edge(max_width : Int32) : String
      "+#{"-" * (max_width - 2)}+"
    end

    def generate_legend_row(legend : String, key : String, max_width : Int32,
                            max_key_chars : Int32) : Array(String)
      max_text_width = max_width - 6 - max_key_chars
      # width - "| " - ": " - " |" - max_key_chars
      # text gets inserted ^^^ there

      l_string = String.build do |str|
        str << key
        if (key.size < max_key_chars)
          str << (" " * (max_key_chars - key.size))
        end
        str << ": "
        legend_lines = wrap_string_to_width(legend, max_text_width)
        if legend_lines.size == 1
          str << legend_lines.first
        else
          legend_lines.each_with_index do |line, idx|
            if idx > 0
              str << " " * (max_key_chars + 2)
              str << line
            else
              # "| <key>: " is already there
              str << line
            end
            str << "\n" if idx != legend_lines.size - 1
          end
        end
      end
      l_string.split("\n")
    end

    def wrap_string_to_width(string : String, width : Int32) : Array(String)
      remaining_space = width
      words = string.split(/\s+/)
      # FIXME not handling newlines correctly
      # they'll be replaced wih spaces
      lines = Array(String).new
      line_buffer = Array(String).new
      words.each do |word|
        fits = word_fits_in_line_buffer?(line_buffer, word, width)
        if line_buffer.empty? || fits
          line_buffer.push(word)
        else
          !line_buffer.empty? # doesn't fit
          lines.push(line_buffer.join(" "))
          line_buffer = Array(String).new
          line_buffer.push(word)
        end
      end
      if !line_buffer.empty?
        lines.push(line_buffer.join(" "))
      end
      lines
    end

    private def buffer_char_size(buffer : Array(String)) : Int32
      return 0 if buffer.empty?
      buffer.map { |b| b.size }.reduce { |accumulator, i| accumulator + i } + buffer.size - 1
      # or buffer.join(" ").size
    end

    private def word_fits_in_line_buffer?(line_buffer : Array(String), word : String, max : Int32) : Bool
      return false if word.size > max
      b_chars = buffer_char_size(line_buffer)
      remaining_chars = (max - (b_chars + 1)) # +1 for the space we'll need
      if remaining_chars >= word.size
        return true
      end
      false
    end
  end
end
