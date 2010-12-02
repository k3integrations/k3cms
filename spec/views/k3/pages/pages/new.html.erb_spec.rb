require 'spec_helper'

describe "k3_pages_pages/new.html.erb" do
  before(:each) do
    assign(:page, stub_model(K3::Pages::Page).as_new_record)
  end

  it "renders new page form" do
    render

    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    assert_select "form", :action => k3_pages_pages_path, :method => "post" do
    end
  end
end
