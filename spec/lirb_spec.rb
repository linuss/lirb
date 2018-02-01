RSpec.describe Lirb do
  it "has a version number" do
    expect(Lirb::VERSION).not_to be nil
  end

  it "can evaluate number" do
    expect(Lirb::Number.new("1").eval).to eq 1
  end

  it "can parse a (simple) program" do
    expect(Lirb::Parser.new("1").run).to eq 1
  end

  it "can evaluate simple function application" do
    expect(Lirb::Parser.new("(+ 1 2)").run).to eq 3
    expect(Lirb::Parser.new("(- 1 2)").run).to eq -1
    expect(Lirb::Parser.new("(+ -1 4)").run).to eq 3
    expect(Lirb::Parser.new("(/ 10 2)").run).to eq 5
    expect(Lirb::Parser.new("(+ 1 2 3)").run).to eq 6
    expect(Lirb::Parser.new("(> 5 1)").run).to be true
    expect(Lirb::Parser.new("(< 5 1)").run).to be false
  end

  it "can evaluate nested expressions" do
    expect(Lirb::Parser.new("(+ (+ 1 2) (+ 3 4))").run).to eq 10 
    expect(Lirb::Parser.new("(/ (+ 5 5) (- 3 4))").run).to eq -10 
  end

  it "can evaluate if-else expressions" do
    expect(Lirb::Parser.new("(if (> 3 2) 2 1)").run).to eq 2
    expect(Lirb::Parser.new("(if (> (+ 3 2) (- 10 2)) 2 1)").run).to eq 1 
  end

  it "can evaluate multiple expressions, returning only the last" do
    expect(Lirb::Parser.new("(+ 1 2) (+ 3 4)").run).to eq 7
  end

  it "can assign a variable" do
    expect(Lirb::Parser.new("(def a 3)").run).to eq 3
    expect(Lirb::Parser.new("(def x 3) (+ x 1)").run).to eq 4
  end

  it "can evaluate a list" do 
    expect(Lirb::Parser.new("[1 2]").run).to eq [1,2]
    expect(Lirb::Parser.new("[(+ 1 2) 4]").run).to eq [3, 4]
  end

  it "can conj to a list" do
    expect(Lirb::Parser.new("(conj [1 2] 3)").run).to eq [1,2,3]
  end

end
