module K3cms
  module Pages
    class PagesController < K3cms::Pages::BaseController
      load_and_authorize_resource :page, :class => 'K3cms::Page', :except => :not_found

      def index
        respond_to do |format|
          format.html # index.html.erb
          format.xml  { render :xml  => @pages }
          format.json { render :json => @pages }
        end
      end

      def show
        respond_to do |format|
          format.html # show.html.erb
          format.xml  { render :xml  => @page }
          format.json { render :json => @page }
        end
      end

      def new
        respond_to do |format|
          format.html # new.html.erb
          format.xml  { render :xml  => @page }
          format.json { render :json => @page }
        end
      end

      def create
        @page.attributes = params[:k3cms_page]
        @page.set_default_title_or_url
        @page.author = current_user

        respond_to do |format|
          if @page.save
            format.html do
              session[:edit_mode] = true
              redirect_to(pretty_edit_k3cms_page_path(@page, :focus => "##{dom_id(@page)} .editable[data-attribute=body]"),
                          :notice => 'Page was successfully created.')
            end
            format.xml  { render :xml => @page, :status => :created, :location => @page }
            format.json { render :nothing =>  true }
          else
            format.html { render :action => "new" }
            format.xml  { render :xml => @page.errors, :status => :unprocessable_entity }
            format.json { render :nothing =>  true }
          end
        end
      end

      def edit
        # What's this for?
        @page.valid?
      end

      def update
        respond_to do |format|
          if @page.update_attributes(params[:k3cms_page])
            format.html { redirect_to(k3cms_page_url(@page), :notice => 'Page was successfully updated.') }
            format.xml  { head :ok }
            format.json { render :json => {} }
          else
            format.html { render :action => "edit" }
            format.xml  { render :xml => @page.errors, :status => :unprocessable_entity }
            format.json { render :json => {:error => @page.errors.full_messages.join('<br/>')} }
          end
        end
      end

      def destroy
        @page.destroy
        respond_to do |format|
          format.html { redirect_to(k3cms_pages_url) }
          format.xml  { head :ok }
          format.json { render :nothing =>  true }
        end
      end

    end
  end
end
