#!/usr/bin/env ruby

# Copyright (c) 2016-2018 Aleksey Cheusov <vle@gmx.net>
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

def number_or_nil(string)
  num = string.to_i
  if num.to_s == string
    num
  else
    nil
  end
end

class LabelIdGenerator
  def initialize
    @label_map = ENV["HSVM_LABEL_MAP"]
    @new_features = {}

    if @label_map != nil
      @label_map.split(" ").each do |p|
        pair = p.split(":")
        num = number_or_nil(pair[1])
        if num == nil
          STDERR.puts("Incorrect numeric identifier within HSVM_LABEL_MAP environment variable")
          exit 1
        end
        @new_features[pair[0]] = num
      end
    end
  end

  def get_id(feature)
    if @new_features.has_key?(feature) then
      return @new_features [feature]
    elsif @label_map == nil
      @new_features [feature] = @new_features.size()
    else
      STDERR.puts("Unknown label \'#{feature}\', set HSVM_LABEL_MAP environment variable properly")
      exit 1
    end
  end

  attr_reader :new_features, :new_features_cnt
end

class FeatureIdGenerator
  def initialize
    @new_features = {}
  end

  def get_id(feature)
    if @new_features.has_key?(feature) then
      @new_features [feature]
    else
      @new_features [feature] = @new_features.size() + 1
    end
  end

  attr_reader :new_features, :new_features_cnt
end

class_gen = LabelIdGenerator.new
feature_gen = FeatureIdGenerator.new

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
      tokens[i][1] = tokens[i][1]
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
