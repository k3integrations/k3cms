module K3cms::Core::CoreHelper
  def self.included(base)
    #puts "#{self} was included"
  end

  def k3cms_init
    render :template => 'k3cms/init'
  end
end

