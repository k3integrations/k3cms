module K3
  module InlineEditor
    module InlineEditorHelper
      def self.included(base)
        #puts "#{self} was included"
      end

      def inline_editable(tag_name, object, attr_name)
        content_tag(tag_name, :class => 'editable', 'data-url' => url_for(object), 'data-object' => dom_class(object), 'data-attribute' => attr_name,  'data-formtype' => "inline_editor") do
          capture { yield }.try(:strip)
        end
      end
    end
  end
end


