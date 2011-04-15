class K3cms::PagesCell < Cell::Rails
  helper K3cms::InlineEditor::InlineEditorHelper
  helper K3cms::Ribbon::RibbonHelper

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
