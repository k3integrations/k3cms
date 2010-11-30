module K3
  module Pages
    class PageNotFound
      unloadable

      def initialize(app, message = "Response Time")
        @app = app
        @message = message
      end

      def call(env)
        pages = Page.where(:url => env['PATH_INFO']).all
        Rails.logger.debug "... env['PATH_INFO']=#{env['PATH_INFO'].inspect}"

        if pages.any? and (page = pages.first)
          env['PATH_INFO'] = "/pages/#{page.id}"
          Rails.logger.debug "... Serving page via #{env['PATH_INFO']}"
          @status, @headers, @response = @app.call(env)

        else
          # Continue processing stack
          @status, @headers, @response = @app.call(env)
          if @status == 404
            Rails.logger.debug "... PageNotFound: Handling 404"
            [404, {"Content-Type" => "text/html"}, 'The page you have requested could not be found. Create it now? (if logged in)']

          else
            [@status, @headers, @response]
          end
        end
      end
    end
  end
end
