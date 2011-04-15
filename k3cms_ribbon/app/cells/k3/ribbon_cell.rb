class K3::RibbonCell < Cell::Base

  helper K3::Ribbon::RibbonHelper

  def show
    @page = @options[:current_page]
    render if k3_user.k3_permitted?(:view_ribbon)
  end

  def drawer
    render
  end
end
