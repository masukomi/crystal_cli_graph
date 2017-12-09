require "crystal_fmt"

module CrystalCliGraph
  class Graph
    getter :data
    BAR_TOPPER="o"
    @columns : Array(Column)
    def initialize(@data : Array(Int32), options : Hash(Symbol, Bool|Int32|String))
      @fit_min = options.has_key?(:fit_min) ? options[:fit_min].as(Bool) : false
      @max_height = options.has_key?(:max_height) ?  options[:max_height].as(Int32) : 15
      @x_label = options.has_key?(:x_label) ? options[:x_label].as(String?) : nil
      @y_label = options.has_key?(:y_label) ? options[:y_label].as(String?) : nil
      @min_width = options.has_key?(:min_width)
      # we need to take 
      # [0, 1, 15, 20, 2]
      # and convert it into height bars.
      @columns = generate_columns_from_data(@data, @fit_min, @max_height,
                                            @y_label)
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
    def generate_columns_from_data(data : Array(Int32), fit_min : Bool,
                                        max_height : Int32,
                                        y_label : String?)
      # we have max_height + 1 possible different bars (+1 for zero height)
      # each bar being able to have 1 step towards max_height
      columns = Array(Column).new(data.size)
      min_range = fit_min ? data.min : 0
      bar_range = data.max - min_range
      bar = bar_range.to_f / (max_height - 1).to_f
      bar = 1 if bar < 1
      
      if !y_label.nil?
        y_label_columns = generate_y_label_columns(max_height, y_label.to_s)
        columns += y_label_columns
      end
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
        if (idx < data.size - 1)
        columns.push(Column.new(Array(String|Nil).new()+(" " *
                                                   column_data.size).split("")))
        end
      end
      columns
    end
    
    private def generate_y_label_columns(max_height : Int32, y_label : String)
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
