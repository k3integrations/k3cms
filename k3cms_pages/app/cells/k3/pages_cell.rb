class K3::PagesCell < Cell::Rails
  helper K3::InlineEditor::InlineEditorHelper
  helper K3::Ribbon::RibbonHelper

  before_filter :set_common_variables
private
  def set_common_variables
    @page = options[:page]
  end

public
  def init
    render
  end

  def metadata_drawer
    render
  end

end
