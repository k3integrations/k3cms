require File.dirname(__FILE__) + '/../spec_helper'

describe 'Range' do
  # before(:all) { setup_browsers(:firefox, :safari, :iexplore9) }
  before(:all) { setup_browsers(:iexplore9) }
  before(:all) { start_browsers }
  after(:all)  { close_browsers }
  
  describe 'constructor' do

    it 'with no parameters' do
      @all_browsers.each do |browser|
        browser.open 'blank.html'
        browser.run_script(
          'x = new InlineEditor.Range();'
        )
        browser.js_eval('!! window.x').should == 'true'
        browser.js_eval('window.x.window === window').should == 'true'
        browser.js_eval('window.x.document === window.document').should == 'true'
        browser.js_eval('!! window.x.range').should == 'true'
      end
    end

    it 'with an element' do
      @all_browsers.each do |browser|
        browser.open 'element.html'
        browser.run_script(
          'x = new InlineEditor.Range(new InlineEditor.Element($(\'#elem\')[0]));'
        )
        browser.js_eval('!! window.x').should == 'true'
        browser.js_eval('window.x.window === window').should == 'true'
        browser.js_eval('window.x.document === window.document').should == 'true'
        browser.js_eval('!! window.x.range').should == 'true'
      end
    end

  end

  describe 'inrtersectsNode' do
    it 'fully containing' do
      @all_browsers.each do |browser|
        browser.open 'element.html'
        browser.run_script(
          '$(\'#elem\')[0].innerHTML = \'<div id="outer">a<span id="inner">b</span>c</div>\';' +
          'outerrange = new InlineEditor.Range(new InlineEditor.Element($(\'#outer\')[0]));' +
          'innerrange = new InlineEditor.Range(new InlineEditor.Element($(\'#inner\')[0]));' +
          'resultouter = outerrange.intersectsRange(innerrange);' +
          'resultinner = innerrange.intersectsRange(outerrange);'
        )
        browser.js_eval('!! window.outerrange').should == 'true'
        browser.js_eval('!! window.innerrange').should == 'true'
        browser.js_eval('window.resultouter').should == 'true'
        browser.js_eval('window.resultinner').should == 'true'
      end
    end
  end
end
