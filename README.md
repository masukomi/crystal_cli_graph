# crystal_cli_graph

A simple command line graphing library for Crystal. It can make graphs: 

* to specified heights and widths
* with optional Y Axis Labels
* with optional key's and legends for the items in the graph.

```
 |
 |
 |
Y|
 |
A|
x|                                    ▁
i|                                ▁   █
s|                            ▁   █   █
 |                        ▁   █   █   █
L|                    ▁   █   █   █   █
a|                ▁   █   █   █   █   █
b|            ▁   █   █   █   █   █   █
e|        ▁   █   █   █   █   █   █   █
l|▁   ▁   █   █   █   █   █   █   █   █
  a   b   c   d   e   f   g   h   i   j
+-------------------------------------+
| a: label-1 x                        |
| b: label-2 xxxxxxxx                 |
| c: label-3 xxxxxx                   |
| d: label-4                          |
| e: label-5 xxxxxxxx                 |
| f: label-6 xx                       |
| g: label-7 xxxxxxxxx                |
| h: label-8 xxxxxxxxx                |
| i: label-9 x                        |
| j: label-10 xx                      |
+-------------------------------------+
```



## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  crystal_cli_graph:
    github: masukomi/crystal_cli_graph
```

## Usage

```crystal
require "crystal_cli_graph"

options = Hash(Symbol, Bool | Int32 | String? | Array(String)).new
  # fit_min       => optional Bool
  # max_height    => optional Int32
  #   The max_height will be exceeded if the length of the y_axis_label
  #   is bigger than the number specified.
  # max_width     => optional Int32
  #   It will attempt to create a graph of this width (if specified). 
  #   The max_width will be exceeded if there is more data provided 
  #   than the max_width allows. 
  #   Addition of enough elements + labels can also cause it to exceed max_width
  #   because of the need for unique keys.
  # y_axis_label  => optional String
  # column_labels => optional Array(String)
  #   If you provide labels for the columns there will be a legend.
  #   If you don't, there won't. 
  # no_legend     => Optional Bool
  #   If you say no_legend and don't provide labels it'll just generate a graph
  #   If you say no_legend and _do_ provide labels it'll use those under
  #   each graph line instead of generating them itself.
  # column_body   => Optional String
  #   Columns are made of the column_body character and topped with the
  #   bar_topper character. See example.cr for how this can be used.
  # bar_topper    => Optional String
  #   the bar_topper is displayed at the top of each bar, even if there
  #   is a zero value. Without it empty bars can be hard to see. See 
  #   example.cr for how this can be used.

data = [1, 2, 3]
labels = ["foo", "bar", "baz"]
options[:column_labels] = labels
options[:y_axis_label] = "Y Axis Label"
g = CrystalCliGraph::Graph.new(data, options)
puts g.generate
```

## Development

Features will be added as needed, or as PR contributions are made. The goal is to
eventually have support for bar graphs that look like bars not just lines, 
maybe line graphs. Who knows. 

## Contributing

1. Fork it ( https://github.com/masukomi/crystal_cli_graph/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [masukomi](https://github.com/masukomi) masukomi - creator, maintainer
