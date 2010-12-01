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
          @app.call(env)

        else
          # Continue processing stack
          @status, @headers, @response = @app.call(env)
          if @status == 404
            Rails.logger.debug "... PageNotFound: Handling 404"
            env['PATH_INFO'] = "/pages/not_found"
            @status, @headers, @response = @app.call(env)
            [404, @headers, @response]

          else
            [@status, @headers, @response]
          end
        end
      end
    end
  end
end
