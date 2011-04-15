namespace :k3cms do
  def k3cms_invoke(taskname)
    Rake::Task.tasks.each do |t|
      next unless t.name =~ /^k3cms:\w+:#{taskname}/
      puts "Invoking #{t}"
      Rake::Task[t].invoke
    end
  end
  
  desc 'Install all K3cms gems'
  task :install do
    k3cms_invoke 'install'
  end

  desc 'Copy public files from all K3cms gems'
  task :copy_public do
    k3cms_invoke 'copy_public'
  end

  desc 'Copy migration files from all K3cms gems'
  task :copy_migrations do
    k3cms_invoke 'copy_migrations'
  end
end
