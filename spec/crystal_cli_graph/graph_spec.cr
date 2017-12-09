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
    columns = g.generate_columns_from_data(default_data, false, 100, nil)
    columns_sizes = columns.map{|x|x.size}
    columns.all?{|x| x.size == 100}.should(be_true())
    columns.all?{|x| x.width == 1}.should(be_true())
    columns.size.should(eq(7))
  end

  it "should generate a graph with no label" do
    g = CrystalCliGraph::Graph.new(default_data, default_options)
    output = g.generate
    matrix = output.split("\n").map{|row| row.split("")}
    matrix.size.should(eq(15)) # default max_height
    #last row (bottom) first item (left)
    matrix.last.first.should(eq(CrystalCliGraph::Graph::BAR_TOPPER))
  end
end

