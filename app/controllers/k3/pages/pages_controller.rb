module K3
  module Pages
    class PagesController < ApplicationController
      def index
        @pages = K3::Page.all

        respond_to do |format|
          format.html # index.html.erb
          format.xml  { render :xml  => @pages }
          format.json { render :json => @pages }
        end
      end

      def show
        @page = K3::Page.find(params[:id])

        respond_to do |format|
          format.html # show.html.erb
          format.xml  { render :xml  => @page }

          format.json {
            # So we have data-object="k3_page" for rest_in_place so that the params come in as params[:k3_page] like the controller expects (and which works well since form_for @page creates fields named that way).
            # But that causes rest_in_place to expect the json object to be in the form {"k3_page":...}
            # But K3::Page.model_name.element drops the namespace and returns 'page' by default. Here is my workaround:
            K3::Page.model_name.instance_variable_set('@element', 'k3_page')
            # Other options:
            # * Pass include_root_in_json => false in the as_json options?
            # * ActiveRecord::Base.include_root_in_json = false and do render :json => { :k3_page => @page }
            # * ActiveRecord::Base.include_root_in_json = false and modify rest_in_place to not require/expect the element name to be in the JSON object response.
            render :json => @page
          }
        end
      end

      def new
        @page = K3::Page.new(params[:k3_page])

        respond_to do |format|
          format.html # new.html.erb
          format.xml  { render :xml  => @page }
          format.json { render :json => @page }
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
            format.json { render :nothing =>  true }
          else
            format.html { render :action => "new" }
            format.xml  { render :xml => @page.errors, :status => :unprocessable_entity }
            format.json { render :nothing =>  true }
          end
        end
      end

      def update
        @page = K3::Page.find(params[:id])

        respond_to do |format|
          if @page.update_attributes(params[:k3_page])
            format.html { redirect_to(k3_page_url(@page), :notice => 'Page was successfully updated.') }
            format.xml  { head :ok }
            format.json { render :nothing =>  true }
          else
            format.html { render :action => "edit" }
            format.xml  { render :xml => @page.errors, :status => :unprocessable_entity }
            format.json { render :nothing =>  true }
          end
        end
      end

      def destroy
        @page = K3::Page.find(params[:id])
        @page.destroy

        respond_to do |format|
          format.html { redirect_to(k3_pages_url) }
          format.xml  { head :ok }
          format.json { render :nothing =>  true }
        end
      end
    end
  end
end
