module K3cms
  module InlineEditor
    module InlineEditorHelper
      def self.included(base)
        #puts "#{self} was included"
      end

      # For example, 'K3cms_Page'
      def inline_editor_object_class(object)
        object.class.name.gsub('::', '_')
      end

      def inline_editable(tag_name, object, attr_name, options = {})
        raise ArgumentError, "object is nil" unless object
        options.reverse_merge!({
          'data-object-class' => inline_editor_object_class(object),
          'data-object-id'    => object.id,
          #'data-save-type'    => object.new_record? ? 'POST' : 'PUT',
          'data-attribute'    => attr_name
        })
        options.merge!({
          :class           => "editable #{options[:class]}",
        })
        options.reverse_merge!({
          'data-url'       => url_for(object),
        }) unless object.new_record?
        content_tag( tag_name, options) do
          raw capture { yield }.try(:strip)
        end
      end

      def inline_editor_update_page_from_object(object)
        %{
          #{inline_editor_object_class(object)}.updatePage(
            #{inline_editor_object_class(object).to_json},
            #{object.id.to_json},
            #{object.to_json},
            null
          );
        }
      end

    end
  end
end


