namespace :k3 do
  namespace :inline_editor do
    desc "Install K3 Inline Editor"
    task :install => [:copy_public] do
    end
    
    desc "Copy public files"
    task :copy_public do
      #K3::FileUtils.copy_from_gem(K3::InlineEditor, 'public')
      K3::FileUtils.symlink_from_gem K3::InlineEditor, 'inline_editor/core/inline_editor.js', 'public/javascripts/k3/inline_editor.js'
    end
  end
end
