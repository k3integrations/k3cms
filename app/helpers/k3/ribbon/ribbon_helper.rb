module K3::Ribbon::RibbonHelper
  def self.included(base)
    puts "#{self} was included"
  end

  def edit_mode?
    session[:edit_mode]
  end
end

