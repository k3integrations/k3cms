namespace :k3cms do
  namespace :pages do
    desc "Install K3cms Pages"
    task :install => [:copy_public, :copy_migrations] do
    end
    
    desc "Copy public files"
    task :copy_public do
      K3cms::FileUtils.copy_or_symlink_files_from_gem K3cms::Pages, 'public/**/*'
    end
    
    desc "Copy migrations"
    task :copy_migrations do
      K3cms::FileUtils.copy_from_gem K3cms::Pages, 'db/migrate'
    end
  end
end
