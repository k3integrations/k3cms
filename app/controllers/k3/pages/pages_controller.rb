module K3
  module Pages
    class PagesController < ApplicationController
      def index
        @pages = K3::Page.all

        respond_to do |format|
          format.html # index.html.erb
          format.xml  { render :xml => @pages }
        end
      end

      def show
        @page = K3::Page.find(params[:id])

        respond_to do |format|
          format.html # show.html.erb
          format.xml  { render :xml => @page }
        end
      end

      def new
        @page = K3::Page.new(params[:k3_page])

        respond_to do |format|
          format.html # new.html.erb
          format.xml  { render :xml => @page }
        end
      end

      def edit
        @page = K3::Page.find(params[:id])
        @page.valid?
      end

      def create
        @page = K3::Page.new(params[:k3_page])

        respond_to do |format|
          if @page.save
            format.html { redirect_to(k3_page_url(@page), :notice => 'Page was successfully created.') }
            format.xml  { render :xml => @page, :status => :created, :location => @page }
          else
            format.html { render :action => "new" }
            format.xml  { render :xml => @page.errors, :status => :unprocessable_entity }
          end
        end
      end

      def update
        @page = K3::Page.find(params[:id])

        respond_to do |format|
          if @page.update_attributes(params[:k3_page])
            format.html { redirect_to(k3_page_url(@page), :notice => 'Page was successfully updated.') }
            format.xml  { head :ok }
          else
            format.html { render :action => "edit" }
            format.xml  { render :xml => @page.errors, :status => :unprocessable_entity }
          end
        end
      end

      def destroy
        @page = K3::Page.find(params[:id])
        @page.destroy

        respond_to do |format|
          format.html { redirect_to(k3_pages_url) }
          format.xml  { head :ok }
        end
      end
    end
  end
end
