require "../spec_helper"

describe CrystalCliGraph::Graph do
  it "should show me an example graph" do
    labels = default_labels(5)
    labels[3] = "label-3 is surprisingly long. Much longer that it's friends"
    max_label_width = labels.map { |x| x.size }.max + 7
    # "| <key>: <label> |" = 7 extra chars
    l = CrystalCliGraph::Legend.new(default_data(5), labels,
      CrystalCliGraph::KEY_CHARS, 16)
    output = l.generate
    STDERR.puts("\nEXAMPLE LEGEND\n-------------------------------\n#{output}\n-------------------------------")
  end

  it "should expand to fit widest label" do
    labels = ["label-a", "label-b", "label-c", "label-d",
              "1234567890"]
    max_label_width = 17 # longest string + 7 for chrome around it
    # "| <key>: <label> |" = 7 extra chars
    # guaranteed to be > 10
    l = CrystalCliGraph::Legend.new(default_data(5), labels, CrystalCliGraph::KEY_CHARS, 10)
    output = l.generate
    rows = output.split("\n")
    rows.first.size.should(eq(max_label_width))
    rows.map { |r| r.size }.max.should(eq(max_label_width))
    rows[-1].size.should(eq(max_label_width))
  end

  it "should expand to fit the max size" do
    l = CrystalCliGraph::Legend.new(default_data(5), default_labels(5),
      CrystalCliGraph::KEY_CHARS, 40)
    output = l.generate
    rows = output.split("\n")
    rows.first.size.should(eq(40))
  end

  it "should wrap long labels" do
    labels = ["label-a xx", "label-b xxx", "label-c xxxx",
              "label-d is surprisingly long. Much longer that it's friends",
              "label-e xxxx"]
    max_label_width = labels.map { |x| x.size }.max + 7
    # "| <key>: <label> |" = 7 extra chars
    l = CrystalCliGraph::Legend.new(default_data(5), labels,
      CrystalCliGraph::KEY_CHARS, 16)
    output = l.generate
    rows = output.split("\n")
    rows.size.should(eq(18))
  end

  it "start every row with a pipe and space" do
    labels = default_labels(5)
    labels[3] = "label-3 is surprisingly long. Much longer that it's friends"
    max_label_width = labels.map { |x| x.size }.max + 7
    # "| <key>: <label> |" = 7 extra chars
    l = CrystalCliGraph::Legend.new(default_data(5), labels,
      CrystalCliGraph::KEY_CHARS, 16)
    output = l.generate
    rows = output.split("\n")
    rows[1..-2].all? { |r| r.starts_with?("| ") }.should(eq(true))
  end
  it "start end row with a space and pipe" do
    labels = default_labels(5)
    labels[3] = "label-3 is surprisingly long. Much longer that it's friends"
    max_label_width = labels.map { |x| x.size }.max + 7
    # "| <key>: <label> |" = 7 extra chars
    l = CrystalCliGraph::Legend.new(default_data(5), labels,
      CrystalCliGraph::KEY_CHARS, 16)
    output = l.generate
    rows = output.split("\n")
    rows[1..-2].all? { |r| r.ends_with?(" |") }.should(eq(true))
  end
end
