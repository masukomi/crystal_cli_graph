require "crystal_fmt"

module CrystalCliGraph
  class Graph
    getter :data
    BAR_TOPPER = "▁"
    COLUMN_BODY= "█"
    @columns : Array(Column)

    def initialize(@data : Array(Int32), options : Hash(Symbol, Bool | Int32 | String? | Array(String)))
      # @column_body = "x"
      # @bar_topper = "y"
      @fit_min = options.fetch(:fit_min, false).as(Bool)
      @max_height = options.fetch(:max_height, 15).as(Int32)
      @y_axis_label = options.fetch(:y_axis_label, nil).as(String?)
      @max_width = options.fetch(:max_width, @data.size).as(Int32)
      @column_labels = options.fetch(:column_labels, Array(String).new).as(Array(String))
      # max_width WILL be exceeded if there are more data elements than it
      @no_legend = options.fetch(:no_legend, false).as(Bool)
      @column_body = options.fetch(:column_body, COLUMN_BODY).as(String)
      @bar_topper = options.fetch(:bar_topper, BAR_TOPPER).as(String)
      @columns = generate_columns_from_data(@data, @fit_min, @max_height,
        @y_axis_label, @max_width, @column_labels)
    end

    def generate
      t = Table.new(@columns)
      options = Hash(Symbol, String | Bool).new
      options[:left_border] = ""
      options[:right_border] = ""
      options[:divider] = ""
      options[:show_header] = false
      response = String.build do |str|
        str << t.format(options)
        if !@column_labels.empty? && ! @no_legend
          str << "\n"
          l = Legend.new(@data, 
                         @column_labels, 
                         get_graph_key_chars(),
                         t.width)
          str << l.generate
        end
      end
    end
    
    def get_graph_key_chars() : Array(String)
      if @no_legend && !  @column_labels.empty?
        CrystalCliGraph.get_key_chars(@column_labels)
      else
        CrystalCliGraph.get_key_chars(nil)
      end
    end
    def get_padding_columns_count(data : Array(Int32), max_width : Int32, labels : Bool) : Int32
      datums = data.size
      key_chars = get_graph_key_chars()
      if datums >= max_width && datums <= key_chars.size
        return 0
      elsif datums > key_chars.size
        min_padding = datums / key_chars.size # because we'll go a-z, aa-zz, aaa-zzz, etc as needed
        normal_padding = (max_width / datums) - 1
        normal_padding = 0 if normal_padding < 0
        min_padding > normal_padding ? min_padding : normal_padding
      else
        padding = (max_width / datums) - 1
        return (padding > 0 ? padding : 0)
      end
    end

    # TODO REFACTOR ME! OMG SUCH COMPLEXITY!
    def generate_columns_from_data(data : Array(Int32), fit_min : Bool,
                                   max_height : Int32,
                                   y_axis_label : String?,
                                   max_width : Int32,
                                   column_labels : Array(String)) : Array(Column)
      label_columns = column_labels.size > 0
      key_chars = get_graph_key_chars()
      max_key_chars = CrystalCliGraph.calculate_max_key_chars(data, key_chars)

      # we have max_height + 1 possible different bars (+1 for zero height)
      # each bar being able to have 1 step towards max_height

      y_axis_label_columns = y_axis_label.nil? ? Array(Column).new : generate_y_axis_label_columns(max_height, y_axis_label.to_s, label_columns)
      pcc = get_padding_columns_count(data, max_width, label_columns)
      total_cols = data.size + (y_axis_label.nil? ? 0 : y_axis_label_columns.size)

      columns = Array(Column).new(total_cols)
      if !y_axis_label.nil?
        max_height = y_axis_label_columns.first.size
        max_height -= 1 if label_columns # ^^ includes this extra row
        columns += y_axis_label_columns
      end

      min_range = fit_min ? data.min : 0
      bar_range = data.max - min_range
      # TODO: rename "bar" var name
      bar = bar_range.to_f / (max_height - 1).to_f
      bar = 1 if bar < 1

      data.each_with_index do |int, idx|
        bar_height = ((int - min_range) / bar).to_i
        padding_needed = max_height - bar_height # possibly higher based on label
        if bar_height == 0 && padding_needed != 0
          padding_needed -= 1
        end
        column_data = generate_column_data(padding_needed, bar_height,
          label_columns, idx, max_key_chars)
        if (idx < (data.size - 1) && pcc > 0)
          last = column_data.last
          last_size = last.to_s.size
          if last_size < (pcc + 1)
            more_pad = (pcc + 1) - last_size
            column_data[-1] = column_data.last.to_s + (" " * more_pad)
          end
        end
        columns.push(Column.new(column_data))
      end
      columns
    end

    private def generate_column_data(padding_needed : Int32,
                                     bar_height : Int32,
                                     label_columns : Bool,
                                     column_idx : Int32,
                                     max_key_chars : Int32) : Array(String | Nil)
      column_data = Array(String | Nil).new + (
        (" " * padding_needed) +
        @bar_topper +
        (@column_body * (bar_height > 0 ? (bar_height - 1) : 0))
      ).split("")
      #TODO find a more efficient way to do that^^
      if label_columns
        key_for_idx = CrystalCliGraph.generate_key_for_index(column_idx, max_key_chars,
          get_graph_key_chars())
        column_data.push key_for_idx + " "
      end
      column_data
    end

    private def generate_y_axis_label_columns(max_height : Int32, y_axis_label : String, label_columns : Bool) : Array(Column)
      col_data = Array(String | Nil).new
      if y_axis_label.size >= max_height
        max_height = y_axis_label.size
        # bar height is calculated based on bar
        # so it's safe to change this now.
        col_data += y_axis_label.split("")
      else
        row_padding_size = (max_height - y_axis_label.size)
        row_padding = (" " * row_padding_size).split("")
        col_data += row_padding
        col_data += y_axis_label.split("")
      end
      col_data.push(" ") if label_columns

      y_axis_label_column = Column.new(col_data)
      y_axis_height = label_columns ? (y_axis_label_column.size - 1) : y_axis_label_column.size
      y_axis_column_data = Array(String | Nil).new + ("|" * y_axis_height).split("")
      y_axis_column_data.push(" ") if label_columns
      y_axis_column = Column.new(y_axis_column_data)
      [y_axis_label_column, y_axis_column]
    end
  end
end
