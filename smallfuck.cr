require "spec"

def flip(tape : Array(Int32), pointer : Int32)
  tape[pointer] = tape[pointer] == 0 ? 1 : 0
  tape
end

def get_indices(str : String, sub : String)
  char_indices = [] of Int32
  str.each_char_with_index do |char, i|
    char_indices << i if char.to_s == sub
  end
  return char_indices
end

DEBUG = false

def interp(code : String, tape : Array(Int32), pointer : Int32, idx : Int32)
  # return tape if idx >= code.size
  return tape if !(0 <= pointer < tape.size)
  if DEBUG
    puts ["Tape", tape]
    puts ["Code", code]
    puts ["Pointer", pointer, tape[pointer]]
    puts ["Index", idx, code[idx]?]
    puts "--------------------"
  end
  case code[idx]?
  when '>'
    return interp(code, tape, pointer + 1, idx + 1)
  when '<'
    return interp(code, tape, pointer - 1, idx + 1)
  when '*'
    return interp(code, flip(tape, pointer), pointer, idx + 1)
  when '['
    if tape[pointer] == 0
      left_bracket_indices = get_indices(code, "[").select(idx + 1..)
      right_bracket_indices = get_indices(code, "]").select(idx..)
      count_from_back = right_bracket_indices.size - left_bracket_indices.size

      new_idx = right_bracket_indices[-count_from_back]
      return interp(code, tape, pointer, new_idx + 1)
    else
      return interp(code, tape, pointer, idx + 1)
    end
  when ']'
    left_bracket_indices = get_indices(code, "[").select(..idx)
    right_bracket_indices = get_indices(code, "]").select(...idx)
    count_from_front = left_bracket_indices.size - right_bracket_indices.size

    new_idx = left_bracket_indices[count_from_front - 1]
    return interp(code, tape, pointer, new_idx)
  when nil
    return tape
  else
    return interp(code, tape, pointer, idx + 1)
  end
end

def interpreter(code : String, tape : String)
  split_tape = tape.split("").map(&.to_i)
  processed_tape = interp(code, split_tape, 0, 0)
  puts processed_tape.join("")
  processed_tape.join("")
end

describe "Tests" do
  it "should work" do
    interpreter(">*>*", "001010101").should eq("010010101")
  end
  it "should work" do
    interpreter("<<>*>*", "001010101").should eq("001010101")
  end
  it "should work" do
    interpreter(">***>*", "001010101").should eq("010010101")
  end
  it "should work" do
    interpreter("*>[>>*<<*]*", "0100001").should eq("1101001")
  end
  it "should work" do
    interpreter("*>[**]>*>*", "00000").should eq("10110")
  end
  it "should work" do
    interpreter("*asdf[>asdf*]asdf>*", "00000").should eq("11111")
  end
  it "should work" do
    interpreter("[>>[>*<*]<<*]**", "11111").should eq("01001")
  end
end
