module K3::Pages::PagesHelper
  def pretty_k3_page_path(page, options)
    (path = '').tap do
      path << page.url
      path << "?#{options.to_query}"
    end
  end

  def pretty_edit_k3_page_path(page, options = {})
    pretty_k3_page_path(page, options.merge({:edit => 1}))
  end
end

