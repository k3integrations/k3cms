require 'spec_helper'
require 'app/models/k3/page'

module K3
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

    describe "validation" do
      describe "when it has the same url as a Rails route" do
        before do
          path = '/my_test_path'
          Rails.application.routes.draw do
            # Note: The target controller/action must exist or Rails.application.routes.recognize_path will raise ActionController::RoutingError
            match path => 'k3/pages/pages#index'
          end
          @page = Page.new(url: path)
        end

        it "should fail validation" do
          @page.should_not be_valid
          @page.errors[:url].should be_present
        end

      end

      describe "when it has the same url as another page" do
        it "should fail validation" do
          page1 = Page.create(url: '/page1')
          page2 = Page.create(url: '/page1')
          page2.should_not be_valid
          page2.errors[:url].should be_present
        end
      end
    end

    describe 'to_s' do
      it 'should return the title' do
        page = Page.new(:title => 'Home')
        page.to_s.should match(/Home/)
      end
    end


  end
end
