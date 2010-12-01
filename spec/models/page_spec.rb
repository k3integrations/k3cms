require File.expand_path('../../spec_helper', __FILE__)
require 'app/models/k3/pages/page'

module K3
  module Pages

    describe Page do
      describe "when initialized with title 'About Us'" do
        before do
          @page = Page.new(:title => 'About Us')
        end

        it 'sets url accordingly' do
          @page.url.should == '/about-us'
        end
      end

      describe "when initialized with url '/about-us'" do
        before do
          @page = Page.new(:url => '/about-us')
        end

        it 'sets title accordingly' do
          @page.title.should == 'About us'
        end
      end
    end

  end
end

