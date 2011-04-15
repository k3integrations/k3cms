require "rubygems"
gem "rspec"
gem "selenium-client"
require "selenium/client"
require "selenium/rspec/spec_helper"
require "spec/test/unit"

describe "Focusing Adds Editing Class" do
  attr_reader :selenium_driver
  alias :page :selenium_driver

  before(:all) do
    @verification_errors = []
    @selenium_driver = Selenium::Client::Driver.new \
      :host => "localhost",
      :port => 4444,
      :browser => "*chrome",
      :url => "file:///Users/dburry/Public/inline_editor/test.html",
      :timeout_in_second => 60
  end

  before(:each) do
    @selenium_driver.start_new_browser_session
  end
  
  append_after(:each) do
    @selenium_driver.close_current_browser_session
    @verification_errors.should == []
  end
  
  it "test_focusing _adds _editing _class" do
    page.open "test.html"
    begin
        !page.is_element_present("xpath=//div[@id='exampleHtml'][contains(concat(' ', normalize-space(@class), ' '), ' editing ')]").should be_false
    rescue ExpectationNotMetError
        @verification_errors << $!
    end
    page.focus "xpath=//div[@id='exampleHtml']"
    page.click_at "xpath=//div[@id='exampleHtml']", "0,0"
    begin
        page.is_element_present("xpath=//div[@id='exampleHtml'][contains(concat(' ', normalize-space(@class), ' '), ' editing ')]").should be_true
    rescue ExpectationNotMetError
        @verification_errors << $!
    end
  end
end
