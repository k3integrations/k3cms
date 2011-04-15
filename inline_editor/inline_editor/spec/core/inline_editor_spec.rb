require File.dirname(__FILE__) + '/../spec_helper'

describe "InlineEditor" do
  # before(:all)  { setup_browsers(:firefox, :safari, :iexplore9) }
  before(:all)  { setup_browsers(:safari) }
  before(:all) { start_browser_sessions }
  after(:all)  { close_browser_sessions }
  
  it "focusing/clicking should set editable class" do
    @all_browsers.each do |browser|
      browser.open "editor.html"
      browser.is_element_present("//div[@id='editable'][#{contains_class_selector('editing')}]").should be_false
      browser.focus "//div[@id='editable']"
      browser.click_at "//div[@id='editable']", "0,0"
      browser.is_element_present("//div[@id='editable'][#{contains_class_selector('editing')}]").should be_true
    end
  end
end
