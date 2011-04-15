# require "rubygems"
# gem "rspec"
# gem "selenium-client"
require "selenium/client"
require "selenium/rspec/spec_helper"
require "spec/test/unit"

DEFAULT_OPTIONS = {
  :host => "localhost",
  :port => 4444,
  :url => "file:///Users/dburry/Public/inline_editor/spec/html/",
  :timeout_in_second => 15,
  :javascript_framework => :jquery
}

def setup_browsers(*which)
  @all_browsers = []

  if which.include?(:firefox)
    @firefox_browser = Selenium::Client::Driver.new(DEFAULT_OPTIONS.merge({:browser => '*firefox'}))
    @all_browsers << @firefox_browser
  end

  # remember to manually turn off popup blocking in safari!
  if which.include?(:safari)
    @safari_browser = Selenium::Client::Driver.new(DEFAULT_OPTIONS.merge({:browser => '*safari'}))
    @all_browsers << @safari_browser
  end

  if which.include?(:iexplore9)
    @iexplore9_browser = Selenium::Client::Driver.new(DEFAULT_OPTIONS.merge({
      :host => '192.168.1.15', # virtualbox virtual machine, must run in bridged mode and look up the ip manually!
      :browser => '*iexplore',
      :url => 'http://inline_editor/spec/html/', # cannot use file protocol, must set up a real local web server!
      :timeout_in_second => 30 # increased timeout due to slowness...
    }))
    @all_browsers << @iexplore9_browser
  end
  # if which.include?(:chrome)
  #   @chrome_browser = Selenium::Client::Driver.new \
  #     :host => 'localhost',
  #     :port => 4444,
  #     :browser => '*googlechrome',
  #     :url => 'http://inline_editor/spec/html/', # cannot use file protocol, must set up a real local web server!
  #     :timeout_in_second => 30
  #   @all_browsers << @chrome_browser
  # end
  # if which.include?(:opera)
  #   @opera_browser = Selenium::Client::Driver.new \
  #     :host => 'localhost',
  #     :port => 4444,
  #     :browser => '*opera',
  #     :url => 'http://inline_editor/spec/html/', # cannot use file protocol, must set up a real local web server!
  #     :timeout_in_second => 30
  #   @all_browsers << @opera_browser
  # end
end

def start_browsers
  @all_browsers.each { |browser| browser.start_new_browser_session }
end
def close_browsers
  @all_browsers.each { |browser| browser.close_current_browser_session }
end
def contains_class_selector(klass)
  "contains(concat(' ', normalize-space(@class), ' '), ' #{klass} ')"
end
