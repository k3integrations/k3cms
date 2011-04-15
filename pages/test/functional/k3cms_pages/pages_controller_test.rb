require 'test_helper'

class K3cms::Pages::PagesControllerTest < ActionController::TestCase
  setup do
    @page = k3cms_pages(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:k3cms_pages)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create page" do
    assert_difference('K3cms::Pages::Page.count') do
      post :create, :page => @page.attributes
    end

    assert_redirected_to k3cms_page_path(assigns(:page))
  end

  test "should show page" do
    get :show, :id => @page.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @page.to_param
    assert_response :success
  end

  test "should update page" do
    put :update, :id => @page.to_param, :page => @page.attributes
    assert_redirected_to k3cms_page_path(assigns(:page))
  end

  test "should destroy page" do
    assert_difference('K3cms::Pages::Page.count', -1) do
      delete :destroy, :id => @page.to_param
    end

    assert_redirected_to k3cms_pages_path
  end
end
