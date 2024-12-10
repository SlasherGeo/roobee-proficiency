# frozen_string_literal: true

require './LinkedList.rb'

# 'abstract' class- subclasses do the heavy lifting
class WLVar

  attr_reader :var_type, :var_name, :val, :list_head
  attr_accessor :val, :list_head


  def define_variable(x, i)
    #defined in other operations
  end

  def type?
    # defined in other operations
  end

  def GET(x, index, list)
    # defined in other operations
  end

  def SET(x, index, list)
    # defined in other operations
  end

  def print
    # defined in other operations
  end

  def clear
    # defined in Varlist
  end


end

class Varint < WLVar

  def initialize
    @var_name = "none"
    @var_type = "int"
    @val = 0
    super
  end

  # x is the name, i is an int
  def define_variable(x, i)
    @var_name = x
    @val = i
  end

  # x is a varint
  def add_vars(x)
    @val += x.val
  end

  # For SET/VARINT operations
  def SET(i)
    @val = i
  end

  def change_sign
    @val *= -1
  end

  def return_variable
    @val
  end

  def print
    puts "#{@var_name}: #{@val}"
    super
  end

  def type?
    super
    return @var_type
  end
end

class Varlist < WLVar

  def initialize
    @var_type = "list"
    @var_name = "none"
    @list_head = LinkedList.new
    super
  end

  # x is the name
  def define_variable(x)
    @var_name = x
  end

  def add(i)
    @list_head.append i
  end

  # i is either number, variable, or a list.
  def add_nums(i)
    if i.type? == "int"
      @list_head.append i.return_variable
    elsif i.type? == "list"
      @list_head.append_nested i
    end
  end

  # GET for varlist
  # index is an int
  def GET(index)
    count = 0

    curr_node = self.list_head.head

    while curr_node != nil
      if count == index
        if curr_node.nested
          return curr_node.nested
        else
          return curr_node.val
        end
      else
        curr_node = curr_node.next
        count += 1
      end
    end
  end

  def combine(list)
    curr = self.list_head
    new_curr = list.list_head.head

    while new_curr
      if new_curr.nested
        nest_copy = new_curr.deep_copy(new_curr.nested)
        curr.append_nested(nest_copy)
      elsif new_curr.val
        curr.append(new_curr.val)
      end
      new_curr = new_curr.next
    end
  end

  def clear_list
    @list_head.clear
  end

  def print
    self.list_head.print_recur(list_head)
  end


    def copy(list)
      self.list_head = LinkedList.deep_copy(list)
    end

  def type?
    super
    return @var_type
  end
end
