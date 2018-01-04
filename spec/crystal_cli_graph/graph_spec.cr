require "../spec_helper"

describe CrystalCliGraph::Graph do
  it "should show me what it looks like with labels" do
    opts = default_options
    labels = default_labels(54)
    opts[:column_labels] = labels
    opts[:y_axis_label] = "Y Axis Label" # WARNING: THIS BREAKS label keys
    # opts[:x_label] = "X Axis label"
    data = default_data(54)
    g = CrystalCliGraph::Graph.new(data, opts)
    output = g.generate
    STDERR.puts("\nEXAMPLE GRAPH\n-------------------------------\n#{output}\n-------------------------------")
    output.nil?.should(be_false())
  end

  it "should show me what it looks like with labels and no legend" do
    opts = default_options
    labels = "foo", "bar", "baz"
    opts[:column_labels] = labels
    opts[:no_legend] = true
    # opts[:x_label] = "X Axis label"
    data = [1,2,3]
    g = CrystalCliGraph::Graph.new(data, opts)
    output = g.generate
    STDERR.puts("\nEXAMPLE GRAPH 2\n-------------------------------\n#{output}\n-------------------------------")
    output.nil?.should(be_false())
  end
  it "should show me a graph with no labels and no legend" do
    opts = default_options
    opts[:no_legend] = true
    data = [1,2,3]
    g = CrystalCliGraph::Graph.new(data, opts)
    output = g.generate
    STDERR.puts("\nEXAMPLE GRAPH 3\n-------------------------------\n#{output}\n-------------------------------")
    output.nil?.should(be_false())
  end
  it "should be as wide as its data with no labels or legend" do
      it "should show me a graph with no labels and no legend" do
    opts = default_options
    opts[:no_legend] = true
    data = [1,2,3]
    g = CrystalCliGraph::Graph.new(data, opts)

    columns = g.generate_columns_from_data(data,
      false,                    # fit_min
      100,                      # max_height
      nil,                      # y_axis_label
      1,                       # make it as small as possible
      Array(String).new    )               # column_labels
    columns.size.should(eq(3)) # no padding to the right of last one.
    columns.all? { |x| x.width == 1 }.should(eq(true))
  end

  end

  it "should be initializable with an array of ints" do
    g = CrystalCliGraph::Graph.new(default_data, default_options)
    g.should(be_a(CrystalCliGraph::Graph))
  end

  it "should be able to generate even columns from data" do
    g = CrystalCliGraph::Graph.new(default_data, default_options)
    columns = g.generate_columns_from_data(default_data, false, 100, nil, 4,
      Array(String).new)
    columns_sizes = columns.map { |x| x.size }
    columns.all? { |x| x.size == 100 }.should(be_true())
    columns.all? { |x| x.width == 1 }.should(be_true())
  end

  it "should not pad columns when there isn't space" do
    g = CrystalCliGraph::Graph.new(default_data, default_options)
    columns = g.generate_columns_from_data(default_data, false, 100, nil, 4,
      Array(String).new)
    columns.size.should(eq(4))
  end
  it "should pad columns when there is space" do
    g = CrystalCliGraph::Graph.new(default_data, default_options)
    columns = g.generate_columns_from_data(default_data,
      false,                    # fit_min
      100,                      # max_height
      nil,                      # y_axis_label
      16,                       # max_width
      Array(String).new(0)    ) # column_labels
    columns.size.should(eq(4))  # no padding to the right of last one.
    columns.map { |c| c.width }.should(eq([4, 4, 4, 1]))
  end

  # it "should generate label for index < LABEL_CHARS.size" do
  #   # this should be a private method but it's broke so i'm writing a test
  #   g = CrystalCliGraph::Graph.new(default_data, default_options)
  #   label = g.generate_label_for_index(0, 1, CrystalCliGraph::Graph::LABEL_CHARS)
  #   label.should(eq("a"))
  # end
  # it "should generate label for index > LABEL_CHARS.size" do
  #   # this should be a private method but it's broke so i'm writing a test
  #   g = CrystalCliGraph::Graph.new(default_data, default_options)
  #   label = g.generate_label_for_index(52, 2, CrystalCliGraph::Graph::LABEL_CHARS)
  #   label.should(eq("aa")) # aa for 52 because it's counting from zero not 1
  #
  # end
  # it "should generate_y_axis_label_columns correctly when > max_height and w/o labels" do
  #   # this should be a private method but it's broke so i'm writing a test
  #   opts = default_options
  #   opts[:max_height] = 1
  #   opts[:y_axis_label] = "22"
  #   g = CrystalCliGraph::Graph.new(default_data, opts)
  #   columns = g.generate_y_axis_label_columns(1, "22", false)
  #   columns[0].strings.should(eq(["2", "2"]))
  #   columns[1].strings.should(eq(["|", "|"]))
  # end
  # it "should generate_y_axis_label_columns correctly when < max_height and w/o labels" do
  #   opts = default_options
  #   opts[:max_height] = 3
  #   opts[:y_axis_label] = "22"
  #   g = CrystalCliGraph::Graph.new(default_data, opts)
  #   columns = g.generate_y_axis_label_columns(3, "22", false)
  #   columns[0].strings.should(eq([" ", "2", "2"]))
  #   columns[1].strings.should(eq(["|", "|", "|"]))
  # end
  # it "should generate_y_axis_label_columns correctly when < max_height and w/labels" do
  #   # this should be a private method but it's broke so i'm writing a test
  #   opts = default_options
  #   opts[:max_height] = 3
  #   opts[:y_axis_label] = "22"
  #   g = CrystalCliGraph::Graph.new(default_data, opts)
  #   columns = g.generate_y_axis_label_columns(3, "22", true)
  #   columns[0].strings.should(eq([" ", "2", "2", " "]))
  #   columns[1].strings.should(eq(["|", "|", "|", " "]))
  # end
  it "should pad columns to support labels " do
    opts = default_options
    labels = default_labels(53)
    opts[:column_labels] = labels
    data = default_data(53)
    g = CrystalCliGraph::Graph.new(data, opts)
    columns = g.generate_columns_from_data(data,
      false,                    # fit_min
      100,                      # max_height
      nil,                      # y_axis_label
      16,                       # max_width
      labels    )               # column_labels
    columns.size.should(eq(53)) # no padding to the right of last one.
    columns.all? { |x| x.width == 3 }.should(eq(true))
    # 3 because 2 letters + 1 space of padding
  end

  it "should generate a graph with no label" do
    g = CrystalCliGraph::Graph.new(default_data, default_options)
    output = g.generate
    matrix = output.split("\n").map { |row| row.split("") }
    matrix.size.should(eq(15)) # default max_height
    # last row (bottom) first item (left)
    matrix.last.first.should(eq(CrystalCliGraph::Graph::BAR_TOPPER))
  end

  it "should not be taller with a short y_axis_label" do
    opts = default_options.dup
    opts[:y_axis_label] = "shorty label"
    g = CrystalCliGraph::Graph.new(default_data, opts)
    output = g.generate
    matrix = output.split("\n").map { |row| row.split("") }
    matrix.size.should(eq(15)) # default max_height
  end
  it "should not be taller with an equally sized y_axis_label" do
    opts = default_options.dup
    opts[:y_axis_label] = "a short y_label" # 15 chars
    g = CrystalCliGraph::Graph.new(default_data, opts)
    output = g.generate
    matrix = output.split("\n").map { |row| row.split("") }
    matrix.size.should(eq(15)) # default max_height
  end
  it "should be taller with a tall y_axis_label" do
    opts = default_options.dup
    opts[:y_axis_label] = "this y_axis_label is like really tall" # 37 chars
    g = CrystalCliGraph::Graph.new(default_data, opts)
    output = g.generate
    matrix = output.split("\n").map { |row| row.split("") }
    matrix.size.should(eq(37)) # default max_height
  end

  it "should render the y_axis_label vertically in the 1st column" do
    opts = default_options.dup
    opts[:y_axis_label] = "this y_axis_label is like really tall" # 32 chars
    g = CrystalCliGraph::Graph.new(default_data, opts)
    output = g.generate
    matrix = output.split("\n").map { |row| row.split("") }
    reconstituted_arr = Array(String).new
    (0...matrix.size).each do |idx|
      reconstituted_arr.push matrix[idx][0]
    end
    reconstituted_arr.join("").should(eq(opts[:y_axis_label]))
  end
  it "should render the y_axis_label vertically in the 1st column with padding" do
    opts = default_options.dup
    opts[:y_axis_label] = "this" # 32 chars
    g = CrystalCliGraph::Graph.new(default_data, opts)
    output = g.generate
    matrix = output.split("\n").map { |row| row.split("") }
    reconstituted_arr = Array(String).new
    (0...matrix.size).each do |idx|
      char = matrix[idx][0]
      reconstituted_arr.push char unless char == " "
    end
    reconstituted_arr.join("").should(eq(opts[:y_axis_label]))
    matrix[matrix.size - 1][0].should(eq("s")) # rendered vertically, last char
  end

  it "should calculate padding columns when max_width = data size" do
    opts = default_options.dup
    opts[:max_width] = 5
    g = CrystalCliGraph::Graph.new(default_data, opts)
    padding_columns = g.get_padding_columns_count(default_data,
      opts[:max_width].as(Int32),
      false)
    padding_columns.should(eq(0))
  end

  it "should calculate padding columns when max_width < data size" do
    opts = default_options.dup
    opts[:max_width] = 1
    g = CrystalCliGraph::Graph.new(default_data, opts)
    padding_columns = g.get_padding_columns_count(default_data,
      opts[:max_width].as(Int32),
      false)
    padding_columns.should(eq(0))
  end
  it "should calculate padding columns when max_width > data size" do
    opts = default_options.dup
    data = [0, 1, 2, 3, 4, 5] # 6 wide so won't divide evenly
    opts[:max_width] = 20
    g = CrystalCliGraph::Graph.new(data, opts)
    padding_columns = g.get_padding_columns_count(data,
      opts[:max_width].as(Int32),
      false)
    padding_columns.should(eq(2))
    # 1 data column + 2 padding columns * 6 = 18
  end
  it "shouldn't multiply padding when data less than num labels" do
    # [a-z]+[A-Z] = 52 characters (default options for single char labels)
    opts = default_options.dup
    opts[:max_width] = 52
    g = CrystalCliGraph::Graph.new(default_data, opts)
    padding_columns = g.get_padding_columns_count(default_data(52),
      52,
      false)
    padding_columns.should(eq(0))
  end
  it "should multiply padding when data > num labels" do
    # [a-z]+[A-Z] = 52 characters (default options for single char labels)
    opts = default_options.dup
    opts[:max_width] = 20
    data = default_data(53)
    g = CrystalCliGraph::Graph.new(data, opts)
    padding_columns = g.get_padding_columns_count(data,
      53,
      true)
    padding_columns.should(eq(1))
  end
end
