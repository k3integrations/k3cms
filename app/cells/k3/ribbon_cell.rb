class K3::RibbonCell < Cell::Base

  require 'cells/helpers'
  helper Cells::Helpers::CaptureHelper

  helper K3::Ribbon::RibbonHelper

  def show
    @page = @opts[:current_page]
    render if k3_user.k3_permitted?(:view_ribbon)
  end

  def drawer
    render
  end
end
