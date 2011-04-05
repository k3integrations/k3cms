module K3::Core::CoreHelper
  def self.included(base)
    #puts "#{self} was included"
  end

  def k3cms_init
    render :template => 'k3/init'
  end
end

