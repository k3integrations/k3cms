require "rubygems"
gem "rspec"
gem "selenium-client"
require "selenium/client"
require "selenium/rspec/spec_helper"
require "spec/test/unit"

describe "Focusing Makes Editable" do
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
  
  it "test_focusing _makes _editable" do
    page.open "test.html"
    page.focus "xpath=//div[@id='exampleHtml']"
    page.click_at "xpath=//div[@id='exampleHtml']", "0,0"
    page.type "xpath=//div[@id='exampleHtml']", "'asdf'"
    begin
        page.is_editable("xpath=//div[@id='exampleHtml']").should be_true
    rescue ExpectationNotMetError
        @verification_errors << $!
    end
  end
end
