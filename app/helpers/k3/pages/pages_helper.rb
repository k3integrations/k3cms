module K3::Pages::PagesHelper
  def pretty_k3_page_path(page)
    page.url
  end

  def pretty_edit_k3_page_path(page)
    page.url + '?edit=1'
  end
end

