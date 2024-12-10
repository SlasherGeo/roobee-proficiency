class Node
  attr_accessor :next, :val, :nested

  def initialize(val = nil, nested_list = nil)
    @next = nil
    @val = val
    @nested = nested_list
  end

end