require 'spec_helper'

describe K3::Authorization::PermissionSet do
  before(:each) do
    @perm_set = K3::Authorization::PermissionSet.new('Name','Description')
  end

  describe "when initialized" do
    it "should set the name and description" do
      @perm_set.name.should == 'Name'
      @perm_set.description.should == 'Description'
    end

    it "should initialize guest, user, manager, and admin to empty lists" do
      @perm_set.guest.should == [].to_set
      @perm_set.user.should == [].to_set
      @perm_set.manager.should == [].to_set
      @perm_set.admin.should == [].to_set
    end
  end
  
  describe "add_abilities" do
    it "should work in the single ability" do
      @perm_set.add_abilities(:guest, :some_ability)
      @perm_set.guest.should == [:some_ability].to_set
    end
    
    it "should work with an array of abilities" do
      @perm_set.add_abilities(:guest, [:some_ability])
      @perm_set.guest.should == [:some_ability].to_set
    end
    
    it "should work with strings as the role param" do
      @perm_set.add_abilities('guest', :something)
      @perm_set.guest.should == [:something].to_set
    end
    
    it "should append the given list of abilities to the given role" do
      [:guest, :user, :manager, :admin].each do |role|
        @perm_set.add_abilities(role, [:first, :second])
        @perm_set.send(role).should == [:first, :second].to_set
        @perm_set.add_abilities(role, [:third])
        @perm_set.send(role).should == [:first, :second, :third].to_set
      end
    end
  end
end
