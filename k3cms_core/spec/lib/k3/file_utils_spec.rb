require File.dirname(__FILE__) + '/../../spec_helper'
require File.dirname(__FILE__) + '/../../../lib/k3/file_utils'

describe K3::FileUtils do
  describe '#copy_recursively' do
    before(:each) do
      @src = '/tmp/k3_core_test/from'
      @dest = '/tmp/k3_core_test/to'
      @src_sub = "#{@src}/sub"
      @dest_sub = "#{@dest}/sub"
      @src_file = "#{@src_sub}/test.txt"
      @dest_file = "#{@dest_sub}/test.txt"
      FileUtils.mkdir_p(@src_sub)
      File.open(@src_file,'w') do |f|
        f.puts 'TEST DATA'
      end
    end
    after(:each) do
      FileUtils.rm_rf('/tmp/k3_core_test')
    end
    
    it "should copy files recursively" do
      K3::FileUtils.copy_recursively(@src,@dest,false)
      File.should be_file(@dest_file)
    end
    
    it "should not overwrite modified files" do
      FileUtils.mkdir_p(@dest_sub)
      File.open(@dest_file,'w') do |f|
        f.puts 'Foo Foo data'
      end
      K3::FileUtils.copy_recursively(@src,@dest,false)
      IO.read(@dest_file).should == "Foo Foo data\n"
    end
  end
end