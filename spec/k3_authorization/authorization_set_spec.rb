require 'spec_helper'

describe K3::Authorization::AuthorizationSet do
  before(:each) do
    @auth_set = K3::Authorization::AuthorizationSet.new
  end
  
  describe "when initialized" do
    it "should initialize suggested_permission_sets and abilities to blank hashs" do
      @auth_set.abilities.should == {}
      @auth_set.suggested_permission_sets.should == {}
    end
  end
  
  describe "draw" do
    before(:each) do
      mock_parser = mock(:parser, :instance_exec => nil)
      K3::Authorization::Parser.should_receive(:new).with(@auth_set).and_return(mock_parser)
      @auth_set.abilities = {:test => 'Test'}
      @auth_set.suggested_permission_sets = {:test => 'Test'}
    end
    
    it "should clear any pre-existing records" do
      @auth_set.draw {}
      @auth_set.abilities.should == {}
      @auth_set.suggested_permission_sets.should == {}
    end
    
    it "should freeze any final records" do
      @auth_set.draw {}
      @auth_set.abilities.should be_frozen
      @auth_set.suggested_permission_sets.should be_frozen
    end
  end
  
  describe "clear!" do
    before(:each) do
      @auth_set.abilities = {:test => 'Test'}
      @auth_set.suggested_permission_sets = {:test => 'Test'}
    end
    
    it "should reset the abilities and suggested_permission_sets" do
      @auth_set.clear!
      @auth_set.abilities.should == {}
      @auth_set.suggested_permission_sets.should == {}
    end
  end
  
  describe "freeze!" do
    it "should reset the abilities and suggested_permission_sets" do
      @auth_set.freeze!
      @auth_set.abilities.should be_frozen
      @auth_set.suggested_permission_sets.should be_frozen
    end
  end
  
  describe "default_suggested_permission_set" do
    before(:each) do
      @auth_set.suggested_permission_sets[:default] = 'Test'
    end
    
    it "should return the default suggested permission set" do
      @auth_set.default_suggested_permission_set.should == 'Test'
    end
  end
end
