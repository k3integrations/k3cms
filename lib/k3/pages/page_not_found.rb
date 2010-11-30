module K3
  module Pages
    class PageNotFound
      def initialize(app, message = "Response Time")
        @app = app
        @message = message
      end

      def call(env)
        @start = Time.now
        @status, @headers, @response = @app.call(env)
        @stop = Time.now
        [@status, @headers, self]
      end

      def each(&block)
        if @headers["Content-Type"] and @headers["Content-Type"].include? "text/html"
          block.call("<!-- #{Page.count} pages -->\n")
        end
        @response.each(&block)
      end
    end
  end
end
