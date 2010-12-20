class K3::PagesCell < Cell::Rails

  def last_saved_status
    @page = @opts[:page]
    if @page && !@page.new_record?
      render
    end
  end

end
