class K3cms::RibbonCell < Cell::Base

  helper K3cms::Ribbon::RibbonHelper
  helper K3cms::InlineEditor::InlineEditorHelper
  include ActionController::RecordIdentifier

  def show
    @page = @options[:current_page]
    render if k3cms_user.k3cms_permitted?(:view_ribbon)
  end

  def drawer
    render
  end

  def context_ribbon_js(record, options = {})
    @record          = record
    @extra_params    = options[:extra_params] || {}
    @new_record_path = options[:new_record_path] || send("new_#{dom_class(@record)}_path")
    @ribbon_offset   = options[:ribbon_offset] || [-0, -5] # (y, x)
    render if edit_mode?
  end

end
