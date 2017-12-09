require "../spec_helper"

def default_options()
  options = Hash(Symbol, Bool|Int32|String).new()
  #fit_min
  #max_height
  #x_label
  #y_label
end
def default_data()
  [0,1,2,3]
end
describe CrystalCliGraph::Graph do
  it "should be initializable with an array of ints" do
    g = CrystalCliGraph::Graph.new(default_data, default_options)
    g.should(be_a(CrystalCliGraph::Graph))
  end

  it "should be able to generate even columns from data" do
    g = CrystalCliGraph::Graph.new(default_data, default_options)
    columns = g.generate_columns_from_data(default_data, false, 100, nil, 4)
    columns_sizes = columns.map{|x|x.size}
    columns.all?{|x| x.size == 100}.should(be_true())
    columns.all?{|x| x.width == 1}.should(be_true())
  end

  it "should not pad columns when there isn't space" do
    g = CrystalCliGraph::Graph.new(default_data, default_options)
    columns = g.generate_columns_from_data(default_data, false, 100, nil, 4)
    columns.size.should(eq(4))
  end
  it "should pad columns when there is space" do
    g = CrystalCliGraph::Graph.new(default_data, default_options)
    columns = g.generate_columns_from_data(default_data, false, 100, nil, 16)
    columns.size.should(eq(13)) # no padding to the right of last one.
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
                                                  opts[:max_width].as(Int32))
    padding_columns.should(eq(0))
  end
  
  it "should calculate padding columns when max_width < data size" do
    opts = default_options.dup
    opts[:max_width] = 1
    g = CrystalCliGraph::Graph.new(default_data, opts)
    padding_columns = g.get_padding_columns_count(default_data, opts[:max_width].as(Int32))
    padding_columns.should(eq(0))
  end
  it "should calculate padding columns when max_width < data size" do
    opts = default_options.dup
    data = [0,1,2,3,4,5] # 6 wide so won't divide evenly
    opts[:max_width] = 20
    g = CrystalCliGraph::Graph.new(data, opts)
    padding_columns = g.get_padding_columns_count(data, opts[:max_width].as(Int32))
    padding_columns.should(eq(2))
    # 1 data column + 2 padding columns * 6 = 18
  end
end

