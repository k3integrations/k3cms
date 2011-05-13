class K3cms::InlineEditorCell < Cell::Base
  helper K3cms::InlineEditor::InlineEditorHelper

  def init_edit_mode
    render if edit_mode?
  end

end
