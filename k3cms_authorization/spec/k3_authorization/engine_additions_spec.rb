require 'spec_helper'

describe Rails::Engine do
  it "should respond_to authorization" do
    Rails::Engine.respond_to?(:authorization).should == true
  end
  
  it "should return an authorization set" do
    Rails::Engine.authorization.should be_an_instance_of(K3::Authorization::AuthorizationSet)
  end
end
