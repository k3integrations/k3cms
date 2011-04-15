require File.dirname(__FILE__) + '/../spec_helper'

describe 'Element' do
  # before(:all) { setup_browsers(:firefox, :safari, :iexplore9) }
  before(:all) { setup_browsers(:safari) }
  before(:all) { start_browser_sessions }
  after(:all)  { close_browser_sessions }
  
  describe 'constructor' do
    
    it 'with a node' do
      @all_browsers.each do |browser|
        browser.open 'element.html'
        browser.js_eval('window.$(\'#elem\').length').should == '1'
        browser.run_script(
          'x = new InlineEditor.Element($(\'#elem\')[0]);'
        )
        browser.js_eval('!! window.x').should be_true
        browser.js_eval('window.x.window === window').should be_true
        browser.js_eval('window.x.document === window.document').should be_true
        browser.js_eval('!! window.x.node').should be_true
      end
    end

  end
end
