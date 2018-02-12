#!/usr/bin/env ruby

# Copyright (c) 2016 Aleksey Cheusov <vle@gmx.net>
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

class IdGenerator
  def initialize
    @new_features = {"-1" => -1, "1" => 1, "+1" => 1, "0" => 0}
    @new_features_cnt = 1
  end
  
  def get_id(feature)
    if @new_features.has_key?(feature) then
      @new_features [feature]
    else
      @new_features_cnt += 1
      @new_features [feature] = @new_features_cnt
    end
  end

  attr_reader :new_features, :new_features_cnt
end

class_gen = IdGenerator.new
feature_gen = IdGenerator.new

#class_gen.get_id("1")
#class_gen.get_id("-1")

while line = gets do
  tokens = line.chop.gsub(/\s+/, " ").split(/ /)
  ids = []
  index_of_pipeline = tokens.index("|")
  tokens[0] = tokens[0].to_i.to_s if tokens[0] =~ /^[-+0-9]/
  tokens[0] = class_gen.get_id(tokens[0])

  if !index_of_pipeline; then
    index_of_pipeline = 0
  end

  (0..index_of_pipeline).each do |idx|
    print "#{tokens[0].to_s} "
    tokens.shift
  end

  (0...tokens.size).each do |i|
    tokens[i] = tokens[i].split(":")

    tokens[i][0] = feature_gen.get_id(tokens[i][0])

    if tokens[i].size == 1
      tokens[i] << 1
    else
      tokens[i][1] = tokens[i][1].to_f
    end
  end
  tokens = tokens.sort_by {|v| v[0]}.uniq {|v| v[0]}.collect {|v| v[0].to_s + ":" + v[1].to_s}

#  puts tokens.inspect
#  (1...tokens.size).each do |i|
#    ids << feature_gen.get_id(tokens[i])
#  end
  puts tokens.join(" ")
end

File.open("token2id.txt", "w") do |file|
  feature_gen.new_features.each do |key, value|
    file.puts (key.to_s + " " + value.to_s)
  end
end

File.open("class2id.txt", "w") do |file|
  class_gen.new_features.each do |key, value|
    file.puts (key.to_s + " " + value.to_s)
  end
end