class K3::InlineEditorCell < Cell::Base

  helper  K3::Ribbon::RibbonHelper
  include K3::Ribbon::RibbonHelper # for edit_mode?
  helper K3::InlineEditor::InlineEditorHelper

  def init_edit_mode
    render if edit_mode?
  end

end
