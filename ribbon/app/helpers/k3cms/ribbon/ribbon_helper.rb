module K3cms::Ribbon::RibbonHelper
  def self.included(base)
    #puts "#{self} was included"
  end

  def k3cms_ribbon
    render_cell 'k3cms/ribbon', :show,
      :k3cms_ribbon_items   => @k3cms_ribbon_items,
      :k3cms_ribbon_drawers => @k3cms_ribbon_drawers
  end

  def k3cms_ribbon_add_item(to_what = :top)
    @k3cms_ribbon_items ||= {}
    @k3cms_ribbon_items[to_what] ||= []
    @k3cms_ribbon_items[to_what] << capture { yield }
    nil
  end

  def k3cms_ribbon_render_drawer(name)
    render_cell('k3cms/ribbon', :drawer, :name => name, :content => capture { yield })
  end

  def k3cms_ribbon_add_drawer(name)
    @k3cms_ribbon_drawers ||= {}
    @k3cms_ribbon_drawers[name] = k3cms_ribbon_render_drawer(name) { yield }
    nil
  end
end

