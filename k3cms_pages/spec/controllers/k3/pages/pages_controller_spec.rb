require 'spec_helper'
require 'app/controllers/k3/pages/pages_controller'

describe K3::Pages::PagesController do

  def mock_page(stubs={})
    (@mock_page ||= mock_model(K3::Page).as_null_object).tap do |page|
      page.stub(stubs) unless stubs.empty?
    end
  end

  describe "GET index" do
    it "assigns all pages as @pages" do
      K3::Page.stub(:all) { [mock_page] }
      get :index
      assigns(:pages).should eq([mock_page])
    end
  end

  describe "GET show" do
    it "assigns the requested page as @page" do
      K3::Page.stub(:find).with("37") { mock_page }
      get :show, :id => "37"
      assigns(:page).should be(mock_page)
    end
  end

  describe "GET new" do
    it "assigns a new page as @page" do
      K3::Page.stub(:new) { mock_page }
      get :new
      assigns(:page).should be(mock_page)
    end
  end

  describe "GET edit" do
    it "assigns the requested page as @page" do
      K3::Page.stub(:find).with("37") { mock_page }
      get :edit, :id => "37"
      assigns(:page).should be(mock_page)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created page as @page" do
        K3::Page.stub(:new).with({'these' => 'params'}) { mock_page(:save => true) }
        post :create, :k3_page => {'these' => 'params'}
        assigns(:page).should be(mock_page)
      end

      it "redirects to the created page" do
        K3::Page.stub(:new) { mock_page(:save => true) }
        post :create, :k3_page => {}
        response.should redirect_to(k3_page_url(mock_page))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved page as @page" do
        K3::Page.stub(:new).with({'these' => 'params'}) { mock_page(:save => false) }
        post :create, :k3_page => {'these' => 'params'}
        assigns(:page).should be(mock_page)
      end

      it "re-renders the 'new' template" do
        K3::Page.stub(:new) { mock_page(:save => false) }
        post :create, :k3_page => {}
        response.should render_template("new")
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested page" do
        K3::Page.should_receive(:find).with("37") { mock_page }
        mock_page.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :k3_page => {'these' => 'params'}
      end

      it "assigns the requested page as @page" do
        K3::Page.stub(:find) { mock_page(:update_attributes => true) }
        put :update, :id => "1"
        assigns(:page).should be(mock_page)
      end

      it "redirects to the page" do
        K3::Page.stub(:find) { mock_page(:update_attributes => true) }
        put :update, :id => "1"
        response.should redirect_to(k3_page_url(mock_page))
      end
    end

    describe "with invalid params" do
      it "assigns the page as @page" do
        K3::Page.stub(:find) { mock_page(:update_attributes => false) }
        put :update, :id => "1"
        assigns(:page).should be(mock_page)
      end

      it "re-renders the 'edit' template" do
        K3::Page.stub(:find) { mock_page(:update_attributes => false) }
        put :update, :id => "1"
        response.should render_template("edit")
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested page" do
      K3::Page.should_receive(:find).with("37") { mock_page }
      mock_page.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the pages list" do
      K3::Page.stub(:find) { mock_page }
      delete :destroy, :id => "1"
      response.should redirect_to(k3_pages_url)
    end
  end

end
