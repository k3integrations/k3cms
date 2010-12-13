require 'thor'

class K3::InlineEditor::Installer < Thor
  include Thor::Actions

  desc 'install', "Install K3 Inline Editor"
  def install
    #get 'https://github.com/janv/rest_in_place/raw/master/javascripts/jquery.rest_in_place.js', 'public/javascripts/jquery.rest_in_place.js'
  end
end

namespace :k3 do
  namespace :inline_editor do
    desc "Install K3 Inline Editor"
    task :install => [:copy_public] do
      K3::InlineEditor::Installer.new([], {}, {:destination_root => Rails.root}).invoke :install
    end
    
    desc "Copy public files"
    task :copy_public do
      # This will probably be released as a separate jQuery plugin (and simply be a dependency), so we don't put it under k3/
      K3::FileUtils.symlink_from_gem K3::InlineEditor, 'inline_editor/core/inline_editor.js', 'public/javascripts/inline_editor.js'

     #K3::FileUtils.copy_from_gem    K3::InlineEditor, 'public'
      # But this is more convenient for development:
      K3::FileUtils.symlink_from_gem K3::InlineEditor, file='public/javascripts/jquery.rest_in_place.js', file
      K3::FileUtils.symlink_from_gem K3::InlineEditor, file='public/javascripts/k3/inline_editor.js',     file
      K3::FileUtils.symlink_from_gem K3::InlineEditor, file='public/stylesheets/k3/inline_editor.css',    file
    end
  end
end
