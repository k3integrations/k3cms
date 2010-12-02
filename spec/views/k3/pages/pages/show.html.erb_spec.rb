require 'spec_helper'

describe "k3_pages_pages/show.html.erb" do
  include Rails.application.routes.url_helpers

  before(:each) do
    @page = assign(:page, stub_model(K3::Pages::Page))
  end

  it "renders attributes in <p>" do
    render
  end
end
