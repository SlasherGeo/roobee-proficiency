# Name: Habeeb Rehman
# UIN: 676308443
# NetId: mrehma22

require './WLInterpreter.rb'

puts "input file: "


file = gets.chomp
fileobj = File.open(file)

# Where the variables that are made will go to
General_map = Hash.new

# global variables for instructions
$flag = 0
$pc_count = 0
$memory = 0

def checker(line)
  if line.include? "VARINT"
    line_split = line.split(' ')

    varint = Varint.new

    numval = line_split[2].to_i

    varint.define_variable(line_split[1], numval)

    General_map.store(varint.var_name, varint)
    $memory += 1

  elsif line.include? "VARLIST"

    list_split = line.split(' ')

    varlist = Varlist.new

    varname = list_split[1]

    # Deleting the fluff
    list_split.delete("VARLIST")
    list_split.delete(varname)

    # to contain the new numbers and lists

    varlist.define_variable(varname)

    # Cleaning up the remaining numbers
    for i in list_split
      i.tr!(',', '') # Gets rid of those commas that are next to the numbers

      if General_map.has_key? i # Check if the arguments provided are variables within memory
        if General_map[i].type? == "int" # If key leads to a varint
          varlist.add_nums General_map[i]
        elsif General_map[i].type? == "list" # if key leads to a varlist
          varlist.add_nums General_map[i]
        end
      else
        new_i = i.to_i # Turn the number to an int
        varlist.list_head.append new_i # add to the list
      end
    end

    General_map.store(varlist.var_name, varlist)
    $memory += 1

  elsif line.include? "COMBINE"
    line_split = line.split " "

    # Assuming both lists are present in the memory
    list1 = General_map[line_split[1]]
    list2 = General_map[line_split[2]]

    list2.combine(list1) # Concatenates the two lists

    # Replace the old entry of list2 with the new one.
    General_map[line_split[2]] = list2

  elsif line.include? "GET"
    line_split = line.split " "

    # Preparing variables

    list_get = General_map[line_split[3]]

    # Grabbing necessary data from the string array
    index = line_split[2].to_i
    name = line_split[1]

    content = list_get.GET(index) # Grabs what's at the index - either an int or a nested list

    # If content is an integer
    if content.is_a? Integer
      if General_map.has_key? name
        var = General_map[name]
        var.SET(content)
        General_map[name] = var
      else
        var = Varint.new
        var.define_variable(name, content)
        General_map.store(name, var)
        $memory += 1
      end

      # If content is a nested list that was grabbed from the list given
    elsif content.is_a? LinkedList
      array_content = content.to_array # turn into array for easier adding
      if General_map.has_key? name
        var = General_map[name]
        var.clear_list
        for i in array_content
          var.add i
        end
        General_map[name] = var
      else
        var = Varlist.new # if the key was not found, make a new list to store the nested list that was grabbed
        var.define_variable(name)
        for i in array_content
          var.add i
        end
        General_map.store(name, var)
        $memory += 1
      end
    end


  elsif line.include? "SET"
    line_split = line.split(" ")
    var = line_split[1]
    index = line_split[2]
    list_name = line_split[3]

    list_set = General_map[list_name]

    # To check if it's a defined var in memory
    # if not, its most likely a constant
    if General_map.has_key? var
      if General_map[var].type? == "int"
        set_var = General_map[var]
        val_of_var = set_var.return_variable
        list_set.list_head.replace(index.to_i, val_of_var)
        General_map[list_name] = list_set
      end
      if General_map[var].type? == "list"
        set_list = General_map[var]
        list_set.list_head.insert_nested(index.to_i, set_list.list_head)
        General_map[list_name] = list_set
      end
    else
      # Replacing a constant into the list and at the index given
      var = var.to_i
      General_map[list_name].list_head.replace(index.to_i, var)
    end

  elsif line.include? "COPY"
    line_split = line.split " "

    # Assuming the 2nd list is already present within memory
    list2 = General_map[line_split[2]] # List to be copied

    list1 = Varlist.new # Where the copied list will go

    if General_map.has_key? line_split[1]
      list1 = General_map[line_split[1]]
    else
      list1.define_variable(line_split[1])
    end

    list1.copy(list2.list_head) # Returns a deep-copy of list2

    temp = General_map.length
    General_map[line_split[1]] = list1 # Overwrite previous entry of list1 (if there was one- if not, it creates a new entry.)
    if General_map.length > temp
      $memory += 1
    end

  elsif line.include? "ADD"
    line_split = line.split " "

    var1 = line_split[1] # grab var1
    var2 = line_split[2] # grab var2

    if General_map.has_key? var1 and General_map.has_key? var2
      final_num = General_map[var1].add_vars(General_map[var2]) # add the two vars together
      General_map[var1].SET(final_num) # store in var1
    end

  elsif line.include? "CHS"
    line_split = line.split " "
    var = line_split[1] # grabs the variable name or constant
    if General_map.has_key? var # If the key is present
      General_map[var].change_sign
    else
      changed_num = var.to_i * -1 # changing the constant's sign and printing it back out.
      puts changed_num
    end
  end
end

# Process(line)
# where the user's inputs are taken in
# (line) is passed to the checker


def process (line)
  input = " "
  if $flag == 0
    puts "input 'o' to execute one line of instruction, 'a' to execute all lines."
    input = gets.chomp
  end

    if input == 'q'
      exit(0)
    end

  # executes a single line - prints out the memory and PC after reading what the line was
    if input == 'o' && $flag == 0
      checker(line)
      puts "Line #: #{$pc_count}\nMemory: #{$memory}"
      $pc_count += 1
    end

  # executes all lines
    if input == 'a' || $flag == 1
      $flag = 1
      $pc_count += 1
      checker(line)
    end


end

# reading in each line
File.foreach(fileobj) do |line|
  if line == "HLT"
    # if all lines were executed with 'a'
    if $flag == 1
      puts "All lines executed."
      $memory = General_map.length
      puts "Lines: #{$pc_count}\nMemory: #{$memory}"
    end
    exit(0)
  end

  process(line)
end


