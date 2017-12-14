require "../spec_helper"

def default_options() : Hash(Symbol, Bool|Int32|String?|Array(String))
  options = Hash(Symbol, Bool|Int32|String?|Array(String)).new()
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
    labels.push "label: #{num}"
  end
  labels
end
describe CrystalCliGraph::Graph do
  it "should be initializable with an array of ints" do
    g = CrystalCliGraph::Graph.new(default_data, default_options)
    g.should(be_a(CrystalCliGraph::Graph))
  end

  it "should be able to generate even columns from data" do
    g = CrystalCliGraph::Graph.new(default_data, default_options)
    columns = g.generate_columns_from_data(default_data, false, 100, nil, 4,
                                           Array(String).new)
    columns_sizes = columns.map{|x|x.size}
    columns.all?{|x| x.size == 100}.should(be_true())
    columns.all?{|x| x.width == 1}.should(be_true())
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
                                           false, # fit_min
                                           100, # max_height
                                           nil, # y_label
                                           16,  # max_width
                                           Array(String).new(0)) # column_labels
    columns.size.should(eq(4)) # no padding to the right of last one.
    columns.map{|c|c.width}.should(eq([4,4,4,1]))
  end


  # it "should generate label for index < LABEL_CHARS.size" do 
  #   # this should be a private method but it's broke so i'm writing a test
  #   g = CrystalCliGraph::Graph.new(default_data, default_options)
  #   label = g.generate_label_for_index(0, 1, CrystalCliGraph::Graph::LABEL_CHARS)
  #   label.should(eq("a"))
  # end
  # it "should generate label for index > LABEL_CHARS.size" do
  #   g = CrystalCliGraph::Graph.new(default_data, default_options)
  #   label = g.generate_label_for_index(52, 2, CrystalCliGraph::Graph::LABEL_CHARS)
  #   label.should(eq("aa")) # aa for 52 because it's counting from zero not 1
  #
  # end
  it "should pad columns to support labels " do
    opts = default_options
    labels = default_labels(53)
    opts[:column_labels] = labels
    data = default_data(53)
    g = CrystalCliGraph::Graph.new(data, opts)
    columns = g.generate_columns_from_data(data, 
                                           false, # fit_min
                                           100, # max_height
                                           nil, # y_label
                                           16,  # max_width
                                           labels) # column_labels
    columns.size.should(eq(53)) # no padding to the right of last one.
    columns.all?{|x|x.width == 2}.should(eq(true))

  end

  it "should generate a graph with no label" do
    g = CrystalCliGraph::Graph.new(default_data, default_options)
    output = g.generate
    matrix = output.split("\n").map{|row| row.split("")}
    matrix.size.should(eq(15)) # default max_height
    #last row (bottom) first item (left)
    matrix.last.first.should(eq(CrystalCliGraph::Graph::BAR_TOPPER))
  end

  it "should not be taller with a short y_label" do
    opts = default_options.dup
    opts[:y_label] = "short y_label"
    g = CrystalCliGraph::Graph.new(default_data, opts)
    output = g.generate
    matrix = output.split("\n").map{|row| row.split("")}
    matrix.size.should(eq(15)) # default max_height
  end
  it "should not be taller with an equally sized y_label" do
    opts = default_options.dup
    opts[:y_label] = "a short y_label" # 15 chars
    g = CrystalCliGraph::Graph.new(default_data, opts)
    output = g.generate
    matrix = output.split("\n").map{|row| row.split("")}
    matrix.size.should(eq(15)) # default max_height
  end
  it "should be taller with a tall y_label" do
    opts = default_options.dup
    opts[:y_label] = "this y_label is like really tall" # 32 chars
    g = CrystalCliGraph::Graph.new(default_data, opts)
    output = g.generate
    matrix = output.split("\n").map{|row| row.split("")}
    matrix.size.should(eq(32)) # default max_height
  end

  it "should render the y_label vertically in the 1st column" do
    opts = default_options.dup
    opts[:y_label] = "this y_label is like really tall" # 32 chars
    g = CrystalCliGraph::Graph.new(default_data, opts)
    output = g.generate
    matrix = output.split("\n").map{|row| row.split("")}
    reconstituted_arr = Array(String).new
    (0...matrix.size).each do |idx|
      reconstituted_arr.push matrix[idx][0] 
    end
    reconstituted_arr.join("").should(eq(opts[:y_label]))
  end
  it "should render the y_label vertically in the 1st column with padding" do
    opts = default_options.dup
    opts[:y_label] = "this" # 32 chars
    g = CrystalCliGraph::Graph.new(default_data, opts)
    output = g.generate
    matrix = output.split("\n").map{|row| row.split("")}
    reconstituted_arr = Array(String).new
    (0...matrix.size).each do |idx|
      char = matrix[idx][0]
      reconstituted_arr.push char unless char == " "
    end
    reconstituted_arr.join("").should(eq(opts[:y_label]))
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
    data = [0,1,2,3,4,5] # 6 wide so won't divide evenly
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

