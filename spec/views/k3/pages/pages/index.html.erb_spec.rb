require 'spec_helper'

describe "k3_pages_pages/index.html.erb" do
  before(:each) do
    assign(:k3_pages_pages, [
      stub_model(K3::Pages::Page),
      stub_model(K3::Pages::Page)
    ])
  end

  it "renders a list of k3_pages_pages" do
    render
  end
end
