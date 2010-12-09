class K3::RibbonCell < Cell::Rails

  helper K3::Ribbon::RibbonHelper

  def show
    @page = K3::Page.new
    render
  end

end
