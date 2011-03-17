namespace :k3 do
  namespace :inline_editor do
    desc "Install K3 Inline Editor"
    task :install => [:copy_public] do
    end
    
    desc "Copy public files"
    task :copy_public do
      if ENV['k3_use_symlinks']
        # This will probably be released as a separate jQuery plugin (and simply be a dependency), so we don't put it under k3/
        K3::FileUtils.symlink_from_gem K3::InlineEditor, 'inline_editor/core/inline_editor.js', 'public/javascripts/inline_editor.js'

        K3::FileUtils.symlink_files_from_gem K3::InlineEditor, 'public/**/*'

      else
        K3::FileUtils.copy_file_from_gem K3::InlineEditor, 'inline_editor/core/inline_editor.js', 'public/javascripts/inline_editor.js'

        K3::FileUtils.copy_from_gem K3::InlineEditor, 'public'
      end
    end
  end
end
