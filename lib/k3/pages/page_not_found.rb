require 'pp'

module K3
  module Pages
    class PageNotFound
      def initialize(app)
        @app = app
      end

      def call(env)
        pages = Page.where(:url => env['PATH_INFO']).all
        Rails.logger.debug "... env['PATH_INFO']=#{env['PATH_INFO'].inspect}"

        if pages.any? and (page = pages.first)
          env['PATH_INFO'] = "/pages/#{page.id}"
          Rails.logger.debug "... Serving page #{page.id} via #{env['PATH_INFO']}"
          @app.call(env)

        else
          # Continue processing stack
          @status, @headers, @response = @app.call(env)

          if @status == 404
            # Use our custom 404 handler
            Rails.logger.debug "... PageNotFound: Handling 404"
            encoded_path = env['PATH_INFO'].to_s.gsub('&', '%26')
            env['QUERY_STRING'] = "requested_path=#{encoded_path}"
            env['PATH_INFO']    = "/pages/not_found"
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
