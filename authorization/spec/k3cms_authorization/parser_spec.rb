require 'spec_helper'
require 'pp'
describe K3cms::Authorization::Parser do
  before(:each) do
    @auth_set = K3cms::Authorization::AuthorizationSet.new
  end
  
  describe "authorization DSL" do
    describe "ability" do
      it "should create an ability and add it to the auth set" do
        @auth_set.draw do
          ability :view, 'View something'
        end
        @auth_set.abilities[:view].should == 'View something'
      end
      
      it "should work with a string instead of a symbol" do
        @auth_set.draw do
          ability 'view', 'View something'
        end
        @auth_set.abilities[:view].should == 'View something'
      end
      
      describe "in context" do
        it "should include context with ability, nesting properly" do
          @auth_set.draw do
            context :pages do
              context :comments do
                ability :view, 'View a page comment'
              end
            end
          end
          @auth_set.abilities[:view_page_comment].should == 'View a page comment'
        end
      end
      
      describe "with invalid names" do
        it "should raise an error with the name of :all" do
          lambda {
            @auth_set.draw do
              ability :all, 'Cannot use this name'
            end
          }.should raise_error(K3cms::Authorization::InvalidAbility)
        end
        
        it "should raise an error with a blank name" do
          lambda {
            @auth_set.draw do
              ability '', 'Cannot leave it blank'
            end
          }.should raise_error(K3cms::Authorization::InvalidAbility)
        end
      end
    end
    
    describe "suggested_permissions_set" do
      it "should create a new suggested permissions set and add it to the auth set" do
        @auth_set.draw do
          suggested_permission_set :test, 'Test Ability'
        end
        perm_set = @auth_set.suggested_permission_sets[:test] 
        perm_set.should be_an_instance_of(K3cms::Authorization::PermissionSet)
        perm_set.name.should == :test
        perm_set.description.should == 'Test Ability'
      end
    end
    
    describe "extend_suggested_permission_set" do
      it "should raise an error if referencing an undefined ability" do
        lambda {
          @auth_set.draw do
            suggested_permission_set :test, 'Test set'

            extend_suggested_permission_set :test do
              guest :has => :undefined_ability
            end
          end
        }.should raise_error(K3cms::Authorization::AbilityUndefined)
      end

      it "should raise an error if attempting to extend an undefined suggested permission set" do
        lambda {
          @auth_set.draw do
            extend_suggested_permission_set :undefined_set do
            end
          end
        }.should raise_error(K3cms::Authorization::SuggestedPermissionSetUndefined)
      end

      it "should raise an error if permission is set without :has key" do
        lambda {
          @auth_set.draw do
            suggested_permission_set :test, 'Test set'
            ability :testable, "Able to test"

            extend_suggested_permission_set :test do
              guest :not_a_hash
            end
          end
        }.should raise_error(K3cms::Authorization::InvalidPermission)
      end

      it "should allow all 4 roles to have a single ability" do
        @auth_set.draw do
          suggested_permission_set :test_set, 'Test Set'
          ability :guest_able, "Guest Able"
          ability :user_able, "User Able"
          ability :manager_able, "Manager Able"
          ability :admin_able, "Admin Able"
          
          extend_suggested_permission_set :test_set do
            guest :has => :guest_able
            user :has => :user_able
            manager :has => :manager_able
            admin :has => :admin_able
          end
        end
        
        perm_set = @auth_set.suggested_permission_sets[:test_set]
        perm_set.guest.should == [:guest_able].to_set
        perm_set.user.should == [:user_able].to_set
        perm_set.manager.should == [:manager_able].to_set
        perm_set.admin.should == [:admin_able].to_set
      end
      
      it "should allow all 4 roles to have a single ability, within context" do
        @auth_set.draw do
          suggested_permission_set :test_set, 'Test Set'
          
          context :pages do
            ability :guest_able, "Guest Able"
            ability :user_able, "User Able"
            ability :manager_able, "Manager Able"
            ability :admin_able, "Admin Able"
          
            extend_suggested_permission_set :test_set do
              guest :has => :guest_able
              user :has => :user_able
              manager :has => :manager_able
              admin :has => :admin_able
            end
          end
        end
        
        perm_set = @auth_set.suggested_permission_sets[:test_set]
        perm_set.guest.should == [:guest_able_page].to_set
        perm_set.user.should == [:user_able_page].to_set
        perm_set.manager.should == [:manager_able_page].to_set
        perm_set.admin.should == [:admin_able_page].to_set
      end
      
      it "should allow all 4 roles to have an array of abilities" do
        @auth_set.draw do
          suggested_permission_set :test_set, 'Test Set'
          
          ability :view, "View a page"
          ability :see, "See a page"
        
          extend_suggested_permission_set :test_set do
            guest :has => [:view, :see]
            user :has => [:view, :see]
            manager :has => [:view, :see]
            admin :has => [:view, :see]
          end
        end
        
        perm_set = @auth_set.suggested_permission_sets[:test_set]
        perm_set.guest.should == [:view, :see].to_set
        perm_set.user.should == [:view, :see].to_set
        perm_set.manager.should == [:view, :see].to_set
        perm_set.admin.should == [:view, :see].to_set
      end
      
      it "should allow all 4 roles to have an array of abilities, in context" do
        @auth_set.draw do
          suggested_permission_set :test_set, 'Test Set'
          
          context :pages do
            ability :view, "View a page"
            ability :see, "See a page"
          
            extend_suggested_permission_set :test_set do
              guest :has => [:view, :see]
              user :has => [:view, :see]
              manager :has => [:view, :see]
              admin :has => [:view, :see]
            end
          end
        end
        
        perm_set = @auth_set.suggested_permission_sets[:test_set]
        perm_set.guest.should == [:view_page, :see_page].to_set
        perm_set.user.should == [:view_page, :see_page].to_set
        perm_set.manager.should == [:view_page, :see_page].to_set
        perm_set.admin.should == [:view_page, :see_page].to_set
      end
      
      it "should allow abilities from an already-defined role to be included with another role" do
        @auth_set.draw do
          suggested_permission_set :test_set, 'Test Set'
          
          context :pages do
            ability :view, "View a page"
            ability :see, "See a page"
          
            extend_suggested_permission_set :test_set do
              guest :has => [:view, :see]
              user :includes_role => :guest
            end
          end
        end
        
        perm_set = @auth_set.suggested_permission_sets[:test_set]
        perm_set.guest.should == [:view_page, :see_page].to_set
        perm_set.user.should == [:view_page, :see_page].to_set
        perm_set.manager.should == [].to_set
        perm_set.admin.should == [].to_set
      end
      
      it "should raise an error if including another role that doesn't have any abilities yet" do
        lambda {
          @auth_set.draw do
            suggested_permission_set :test_set, 'Test Set'
          
            context :pages do
              extend_suggested_permission_set :test_set do
                user :includes_role => :guest
              end
            end
          end
        }.should raise_error(K3cms::Authorization::InvalidPermission)
      end
      
      it "should allow :all abilities to be granted to a role, in context" do
        @auth_set.draw do
          suggested_permission_set :test_set, 'Test Set'
          ability :forsee_the_future, "Yeah right"
          
          context :pages do
            ability :view, "View a page"
            ability :see, "See a page"
          
            extend_suggested_permission_set :test_set do
              guest :has => :all
            end
          end
        end
        
        perm_set = @auth_set.suggested_permission_sets[:test_set]
        perm_set.guest.should == [:view_page, :see_page].to_set
      end
    end
  end
end
