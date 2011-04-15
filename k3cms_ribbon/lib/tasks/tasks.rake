namespace :k3 do
  namespace :ribbon do
    desc "Install K3 Ribbon"
    task :install => [:copy_public, :copy_migrations] do
    end
    
    desc "Copy public files"
    task :copy_public do
      K3::FileUtils.copy_or_symlink_files_from_gem K3::Ribbon, 'public/**/*'
    end
    
    desc "Copy migrations"
    task :copy_migrations do
      K3::FileUtils.copy_from_gem K3::Ribbon, 'db/migrate'
    end
  end
end
