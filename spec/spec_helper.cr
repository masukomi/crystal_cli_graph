require "spec"
require "../src/crystal_cli_graph"

def default_options : Hash(Symbol, Bool | Int32 | String? | Array(String))
  options = Hash(Symbol, Bool | Int32 | String? | Array(String)).new
  # fit_min
  # max_height
  # x_label
  # y_label
  # column_labels
end

def default_data(size : Int32 = 4) : Array(Int32)
  data = Array(Int32).new(size)
  (0...size).each do |x|
    data.push(x)
  end
  data
end

def default_labels(count : Int32) : Array(String)
  labels = Array(String).new
  (1..count).each do |num|
    labels.push "label-#{num} #{"x" * Random.rand(10)}"
  end
  labels
end
