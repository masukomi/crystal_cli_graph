require "crystal_fmt"

module CrystalCliGraph
  class Graph
    getter :data
    BAR_TOPPER="o"
    @columns : Array(Column)
    def initialize(@data : Array(Int32), options : Hash(Symbol, Bool|Int32|String?))
      @fit_min = options.fetch(:fit_min, false).as(Bool)
      @max_height = options.fetch(:max_height, 15).as(Int32)
      @x_label = options.fetch(:x_label, nil).as(String?)
      @y_label = options.fetch(:y_label, nil).as(String?)
      @max_width = options.fetch(:max_width, @data.size).as(Int32)
      # max_width WILL be exceeded if there are more data elements than it
      # we need to take 
      # [0, 1, 15, 20, 2]
      # and convert it into height bars.
      @columns = generate_columns_from_data(@data, @fit_min, @max_height,
                                            @y_label, @max_width)
    end
    def generate
      t = Table.new(@columns)
      options = Hash(Symbol,String|Bool).new
      options[:left_border] = ""
      options[:right_border] = ""
      options[:divider] = ""
      options[:show_header] = false
      t.format(options)
    end

    def get_padding_columns_count(data : Array(Int32), max_width : Int32) : Int32
      datums = data.size
      if datums >= max_width
        return 0
      else
        padding = (max_width / data.size) - 1
        return (padding > 0 ? padding : 0)
      end
    end
    
    def generate_columns_from_data(data : Array(Int32), fit_min : Bool,
                                        max_height : Int32,
                                        y_label : String?,
                                        max_width : Int32)
      # we have max_height + 1 possible different bars (+1 for zero height)
      # each bar being able to have 1 step towards max_height
      y_label_columns = y_label.nil? ? Array(Column).new : generate_y_label_columns(max_height, y_label.to_s)
      pcc = get_padding_columns_count(data, max_width)
      total_cols = data.size + (y_label.nil? ? 0 : y_label_columns.size) + ((data.size * pcc) - pcc)
      
      columns = Array(Column).new(total_cols)
      if !y_label.nil?
        max_height = y_label_columns.first.size
        columns += y_label_columns
      end


      min_range = fit_min ? data.min : 0
      bar_range = data.max - min_range
      bar = bar_range.to_f / (max_height - 1).to_f
      bar = 1 if bar < 1
      
      padding_column = Column.new(Array(String|Nil).new()+(" " * max_height).split(""))
      data.each_with_index do |int, idx|
        bar_height = ((int - min_range) / bar).to_i
        padding_needed = max_height - bar_height # possibly higher based on label
        if bar_height == 0 && padding_needed != 0
          padding_needed -=1
        end
        column_data = Array(String|Nil).new + (
          (" " * padding_needed) + 
          BAR_TOPPER +
          ("|" * ( bar_height > 0 ? (bar_height - 1) : 0 ))).split("")
        # find a more efficient way to do that^^
        columns.push(Column.new(column_data))
        if (idx < data.size - 1 && pcc > 0)
          pcc.times do 
            columns.push(padding_column)
          end
        end
      end
      columns
    end
    
    private def generate_y_label_columns(max_height : Int32, y_label : String) : Array(Column)
      col_data = Array(String|Nil).new()
      if y_label.size >= max_height
        max_height = y_label.size
        # bar height is calculated based on bar
        # so it's safe to change this now.
        col_data += y_label.split("")
      else
        padding = (max_height - y_label.size)
        col_data += (" " * padding).split("")
        col_data += y_label.split("")
      end
      y_label_column = Column.new(col_data)
      y_axis_column_data = Array(String|Nil).new + ("|" *
                                                  y_label_column.size).split("")
      [y_label_column, Column.new(y_axis_column_data)]
    end
  end
end
