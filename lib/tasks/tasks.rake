namespace :k3 do
  namespace :pages do
    desc "Install K3 Pages"
    task :install => [:copy_public, :copy_migrations] do
    end
    
    desc "Copy public files"
    task :copy_public do
      K3::FileUtils.symlink_from_gem K3::Pages, file='public/javascripts/k3/pages.js',  file
      K3::FileUtils.symlink_from_gem K3::Pages, file='public/stylesheets/k3/pages.css',  file
      #K3::FileUtils.copy_from_gem K3::Pages, 'public'
    end
    
    desc "Copy migrations"
    task :copy_migrations do
      K3::FileUtils.copy_from_gem K3::Pages, 'db/migrate'
    end
  end
end
