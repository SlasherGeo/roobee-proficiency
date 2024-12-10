# frozen_string_literal: true

require './Node.rb'

class LinkedList
  attr_accessor :head

  def initialize
    @head = nil
    @length = 0
  end

  # simple append for linked list structure
  def append(val)
    if @head
      find_tail.next = Node.new(val, nil)
      @length += 1
    else
      @head = Node.new(val, nil)
      @length += 1
    end
  end

  # for the sake of appending nested lists - for VARLIST
  def append_nested(nested_list)
    new_node = Node.new(nil, nested_list)

    if @head.nil?
      @head = new_node
    else
      find_tail.next = new_node
    end
  end


  # This function helps with "SET" operations with lists.
  def insert_nested(index, nested_list)
    current = @head
    count = 0

    while current != nil
      if count == index
        current.val = nil
        current.nested = nested_list
        @length += nested_list.length
        break
      end

      count += 1
      current = current.next
    end
  end


  # for my own sanity - returns the head of the list
  def get_head
    return @head
  end


  # Goes to the end of the list
  def find_tail
    node = @head
    return node unless node.next
    return node unless node.next while (node = node.next)
  end

  # Helps with SET - replaces the value at the index provided with a new 'val'
  def replace(index, val)
    count = 0
    new_node = Node.new(val, nil)
    curr_node = @head
    prev_node = nil

    while curr_node != nil
      if count == index
        new_node.next = curr_node.next
        prev_node.next = new_node
        break
      else
        prev_node = curr_node
        curr_node = curr_node.next
        count += 1
      end
    end

  end

  # Deep copies a list onto another.
  def self.deep_copy(list)
    # If list given is empty
    return nil if list.nil?

    new_list = LinkedList.new
    current = list.head

    while current
      if current.val != nil
        new_list.append(current.val)
      elsif current.nested
        nested_copy = self.deep_copy(current.nested)
        new_list.append_nested(nested_copy)
      end

        current = current.next
    end
    new_list
  end

  # Prints the list
  def print_recur(node)
    return if node == nil

    if node.val.nil?
      # If the node has a nested list, print its contents
      node.nested.print_recur(node.nested.head)
    else
      # If the node has a value, print it
      puts node.val
    end

    # Continue to the next node
    print_recur(node.next)
  end



  # Turns list into an array
  # TODO: possibly fix this for nested lists?
  # answer: no.
  def to_array
    head_node = @head
    array_ll = []

    while head_node != nil
      array_ll.append head_node.val
      head_node = head_node.next
    end

    array_ll
  end


  def clear
    @head = nil
    @length = 0
  end

  # MY SANITY
  def length
    @length
  end

end







