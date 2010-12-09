class K3::RibbonCell < Cell::Rails

  def show
    @page = K3::Page.new
    render
  end

end
