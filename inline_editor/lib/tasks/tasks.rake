namespace :k3cms do
  namespace :inline_editor do
    desc "Install K3cms Inline Editor"
    task :install => [:copy_public] do
    end
    
    desc "Copy public files"
    task :copy_public do
      K3cms::FileUtils.copy_or_symlink_files_from_gem K3cms::InlineEditor, 'public/**/*'
      K3cms::FileUtils.copy_or_symlink_files_from_gem K3cms::InlineEditor, 'inline_editor/core/inline_editor.js', 'public/javascripts/inline_editor.js'
    end
  end
end
