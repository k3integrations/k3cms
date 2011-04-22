module K3cms
  module InlineEditor
    module InlineEditorHelper
      def self.included(base)
        #puts "#{self} was included"
      end

      def inline_editable(tag_name, object, attr_name, options = {})
        raise ArgumentError, "object is nil" unless object
        options.reverse_merge!({
          :class           => 'editable',
          'data-object'    => dom_class(object),
          'data-object-id' => dom_id(object),
          'data-attribute' => attr_name
        })
        options.reverse_merge!({
          'data-url'       => url_for(object),
        }) unless object.new_record?
        content_tag( tag_name, options) do
          capture { yield }.try(:strip)
        end
      end


    end
  end
end


