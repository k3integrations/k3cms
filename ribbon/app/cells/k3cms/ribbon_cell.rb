class K3cms::RibbonCell < Cell::Base

  helper K3cms::Ribbon::RibbonHelper

  def show
    @page = @options[:current_page]
    render if k3cms_user.k3cms_permitted?(:view_ribbon)
  end

  def drawer
    render
  end
end
