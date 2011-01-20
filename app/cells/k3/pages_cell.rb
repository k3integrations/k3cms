class K3::PagesCell < Cell::Rails
  helper K3::InlineEditor::InlineEditorHelper
  helper K3::Ribbon::RibbonHelper

  before_filter :set_common_variables
private
  def set_common_variables
    @page = @opts[:page]
  end

public
  def init
    render
  end

  def last_saved_status
    if @page && !@page.new_record?
      render
    end
  end

  def metadata_drawer
    render
  end

end
