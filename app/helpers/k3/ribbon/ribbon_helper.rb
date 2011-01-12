module K3::Ribbon::RibbonHelper
  def self.included(base)
    puts "#{self} was included"
  end

  def add_to_ribbon
    @k3_ribbon_items ||= []
    @k3_ribbon_items << capture { yield }
    nil
  end

  def edit_mode?
    session[:edit_mode] = false if session[:edit_mode].nil?
    session[:edit_mode]
  end
end

