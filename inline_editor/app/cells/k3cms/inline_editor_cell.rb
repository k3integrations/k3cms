class K3cms::InlineEditorCell < Cell::Base
  helper K3cms::InlineEditor::InlineEditorHelper
  include ActionController::RecordIdentifier

  def init_edit_mode
    render if edit_mode?
  end

  def record_editing_js(record, options = {})
    @record          = record
    @extra_params    = options[:extra_params] || {}
    @new_record_path = options[:new_record_path] || send("new_#{dom_class(@record)}_path")
    @ribbon_offset   = options[:ribbon_offset] || [-0, -5] # (y, x)
    render if edit_mode?
  end

end
