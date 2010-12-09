require 'pp'

module K3
  module Pages
    class CustomRouting
      def initialize(app)
        @app = app
      end

      def call(env)
        pages = Page.where(:url => env['PATH_INFO']).all
        Rails.logger.debug "... env['PATH_INFO']=#{env['PATH_INFO'].inspect}"

        if pages.any? and (page = pages.first)
          # Normally the validation will catch this when the page is created,
          # but we need to check here in case anyone ever adds a route *after*
          # the page already exists. We will redirect the user to the edit page
          # and force them to correct the conflicting custom Page url.
          #
          #rails_route = ActionController::Routing::Routes.recognize_path(env['PATH_INFO'], :method => env["REQUEST_METHOD"])
          #
          # TODO: (Only) If logged in as editor, check if this route conflicts with normal Rails routes
          # But how do we check if they're logged in? Inspect rack.session manually?
          #
          if !page.valid?
            env['PATH_INFO'] = "/k3_pages/#{page.id}/edit"
            @app.call(env)

          else
            # Render the page object

            # TODO: Instantiate PagesController and render view more directly, bypassing the Rails router
            #PagesController.new.process_action('show') #render_to_string

            env['PATH_INFO'] = "/k3_pages/#{page.id}"
            Rails.logger.debug "... Serving page #{page.id} via #{env['PATH_INFO']}"
            @app.call(env)
          end

        else
          # Continue processing stack
          @status, @headers, @response = @app.call(env)

          if @status == 404
            # Use our custom 404 handler
            Rails.logger.debug "... CustomRouting: Handling 404"
            encoded_path = env['PATH_INFO'].to_s.gsub('&', '%26')
            env['PATH_INFO']    = "/k3_pages/not_found"
            env['QUERY_STRING'] = "requested_path=#{encoded_path}"
            @status, @headers, @response = @app.call(env)
            [404, @headers, @response]

          else
            [@status, @headers, @response]
          end
        end
        #@app.call(env)
      end
    end
  end
end
