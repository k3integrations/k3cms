class K3::PagesCell < Cell::Rails
  helper K3::InlineEditor::InlineEditorHelper

  def init
    render
  end

  def last_saved_status
    @page = @opts[:page]
    if @page && !@page.new_record?
      render
    end
  end

end
