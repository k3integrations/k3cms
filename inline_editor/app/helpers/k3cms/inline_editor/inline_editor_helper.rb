module K3cms
  module InlineEditor
    module InlineEditorHelper
      def self.included(base)
        #puts "#{self} was included"
      end

      def inline_editable(tag_name, object, attr_name, options = {})
        raise ArgumentError, "object is nil" unless object
        content_tag(
          tag_name,
          {:class => 'editable', 'data-url' => url_for(object), 'data-object' => dom_class(object), 'data-object-id' => dom_id(object), 'data-attribute' => attr_name}.merge(options)
        ) do
          capture { yield }.try(:strip)
        end
      end
    end
  end
end


