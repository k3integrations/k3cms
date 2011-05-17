require 'pp'

module K3cms
  module Pages
    class CustomRouting
      def initialize(app)
        @app = app
      end

      def call(env)
        pages = Page.where(:url => env['PATH_INFO']).all
        env['ORIG_PATH_INFO'] = env['PATH_INFO'].dup
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
          session = env["rack.session"]
          # if key = session['warden.user.user.key']

          if !page.valid?
            env['PATH_INFO'] = "/k3cms_pages/#{page.id}/edit"
            @app.call(env)

          else
            # Render the page object

            # TODO: Instantiate PagesController and render view more directly, bypassing the Rails router?
            # Or perhaps it's not possible/wise to bypass ActionDispatch and before_filters, etc.
            #PagesController.new.process_action('show') #render_to_string

            env['PATH_INFO'] = "/k3cms_pages/#{page.id}"
            Rails.logger.debug "... Serving page #{page.id} via #{env['PATH_INFO']}"
            @app.call(env)
          end

        else
          orig_env = env.dup
          # Continue processing stack
          @status, @headers, @response = @app.call(env)

          if @status == 404
            # Use our custom 404 handler
            Rails.logger.debug "... CustomRouting: Handling 404"
            encoded_path = env['PATH_INFO'].to_s.gsub('&', '%26')

            # The call to @app.call(env) may have modified env in ways we don't want it to have.
            # In particular, with Spree, it would have matched their catch-all route:
            #   match '/*path' => 'content#show'
            # and caused env['action_dispatch.request.parameters'] to look something like
            #   {"controller"=>"content", "action"=>"show", "path"=>"the_unrecognized_path"},
            # That would cause problems when we call @app.call(env) again below
            # Instead of this:
            #   Parameters: {"requested_path"=>"/the_unrecognized_path"}
            # we saw this:
            #   Parameters: {"path"=>"the_unrecognized_path"}
            # To be safe and prevent that from happening, we revert env before tweaking it.
            env = orig_env
            # This seems to also work:
            # env.delete_if {|k,v| k =~ /action_dispatch.request/ }

            env['PATH_INFO']    = "/k3cms_pages/not_found"
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
