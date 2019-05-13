# run this file from within the root of the crystal_cli_graph
# project with 
# crystal example.cr

require "./src/crystal_cli_graph"
# when loading as a shard you would say
# require "crystal_cli_graph"

puts "----------------------------"
puts "Example 1"
puts "----------------------------"
options = Hash(Symbol, Bool | Int32 | String? | Array(String)).new
data = [1, 2, 3]
labels = ["foo", "bar", "baz"]
options[:column_labels] = labels
options[:y_axis_label] = "Y Axis Label"
g = CrystalCliGraph::Graph.new(data, options)
puts g.generate

puts "----------------------------"
puts "Example 2"
puts "----------------------------"
options[:y_axis_label] = nil
options[:max_height] = 5
options[:no_legend] = true
g = CrystalCliGraph::Graph.new(data, options)
puts g.generate

puts "----------------------------"
puts "Example 3"
puts "----------------------------"
options[:y_axis_label] = nil
options[:max_height] = 5
options[:no_legend] = true
options[:column_body] = "|"
options[:bar_topper] = "o"
g = CrystalCliGraph::Graph.new(data, options)
puts g.generate
