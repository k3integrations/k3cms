namespace :k3 do
  namespace :pages do
    desc "Install K3 Pages"
    task :install => [:copy_public, :copy_migrations] do
    end
    
    desc "Copy public files"
    task :copy_public do
      K3::FileUtils.copy_from_gem(K3Pages,'public')
    end
    
    desc "Copy migrations"
    task :copy_migrations do
      K3::FileUtils.copy_from_gem(K3Pages,File.join('db','migrate'))
    end
  end
end