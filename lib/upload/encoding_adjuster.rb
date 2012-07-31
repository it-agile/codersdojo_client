# coding: utf-8

class EncodingAdjuster

  def adjust string
    {"‘" => "'", "’" => "'"}.each_pair do |key, value|
      string = string.gsub(key, value)
    end
    string
  end


end
