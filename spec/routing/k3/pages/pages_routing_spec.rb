require "spec_helper"

describe K3::Pages::PagesController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/pages" }.should route_to(:controller => "k3/pages/pages", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/pages/new" }.should route_to(:controller => "k3/pages/pages", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/pages/1" }.should route_to(:controller => "k3/pages/pages", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/pages/1/edit" }.should route_to(:controller => "k3/pages/pages", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/pages" }.should route_to(:controller => "k3/pages/pages", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/pages/1" }.should route_to(:controller => "k3/pages/pages", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/pages/1" }.should route_to(:controller => "k3/pages/pages", :action => "destroy", :id => "1")
    end

  end
end
