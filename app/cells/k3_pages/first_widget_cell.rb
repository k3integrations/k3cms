class K3Pages::FirstWidgetCell < Cell::Base 
  def one 
    @page = K3Pages::Page.new
    render
  end
  
  def two
    render
  end
end
