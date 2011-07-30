require 'filename'

describe Filename do

  it "should detect if the path is absolute or relative" do
		Filename.new('').absolute_path?.should be_false
		Filename.new('/').absolute_path?.should be_true
		Filename.new('').relative_path?.should be_true
		Filename.new('/').relative_path?.should be_false
  end

  it "should split into path items" do
		Filename.new('').path_items.should == []
		Filename.new('a').path_items.should == ['a']
		Filename.new('/a').path_items.should == ['a']
		Filename.new('/a/').path_items.should == ['a']
		Filename.new('a/b').path_items.should == ['a', 'b']
		Filename.new('/a/b').path_items.should == ['a', 'b']
	end
	
	it "should remove the extension" do
		Filename.new('').without_extension.to_s.should == ''
		Filename.new('a').without_extension.to_s.should == 'a'
		Filename.new('a.b').without_extension.to_s.should == 'a'
		Filename.new('a.b.c').without_extension.to_s.should == 'a.b'
		Filename.new('a.b/c').without_extension.to_s.should == 'a.b/c'
	end
	
	it 'should remove the last element of a dir path' do
		Filename.new('').remove_last_path_item.to_s.should == ""
		Filename.new('/').remove_last_path_item.to_s.should == "/"
		Filename.new('a').remove_last_path_item.to_s.should == ""
		Filename.new('a/').remove_last_path_item.to_s.should == ""
	  Filename.new('/a').remove_last_path_item.to_s.should == "/"
	  Filename.new('/a/').remove_last_path_item.to_s.should == "/"
		Filename.new('a/b').remove_last_path_item.to_s.should == "a"
	end
	
	it 'should extract the last element of a dir path' do
		Filename.new('').extract_last_path_item.to_s.should == ""
		Filename.new('/').extract_last_path_item.to_s.should == ""
		Filename.new('a').extract_last_path_item.to_s.should == "a"
		Filename.new('a/b/').extract_last_path_item.to_s.should == "b"
		Filename.new('a/b/c').extract_last_path_item.to_s.should == "c"
  end

	it "should return a Unix like string representation" do
		Filename.new('a/b').to_unix_s.should == 'a/b'
		Filename.new('/a/b').to_unix_s.should == '/a/b'
		Filename.new('a\\b').to_unix_s.should == 'a/b'
		Filename.new('\\a\\b').to_unix_s.should == '/a/b'
		Filename.new('a/').to_unix_s.should == 'a'
	end

	it "should return a Windows like string representation" do
		Filename.new('a/b').to_windows_s.should == 'a\\b'
		Filename.new('/a/b').to_windows_s.should == '\\a\\b'
		Filename.new('a\\b').to_windows_s.should == 'a\\b'
		Filename.new('\\a\\b').to_windows_s.should == '\\a\\b'
	end

	it "should return a Unix like string representation by default" do
		Filename.new('/a/b').to_s.should == '/a/b'
		Filename.new('a\\b').to_s.should == 'a/b'
	end

end


