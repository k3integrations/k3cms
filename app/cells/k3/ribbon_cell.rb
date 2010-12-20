class K3::RibbonCell < Cell::Rails

  helper K3::Ribbon::RibbonHelper

  def show
    @page = @opts[:current_page]
    render
  end

end
