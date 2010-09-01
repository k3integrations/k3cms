namespace :k3 do
  def k3_invoke(taskname)
    Rake::Task.tasks.each do |t|
      next unless t.name =~ /^k3:\w+:#{taskname}/
      puts "Invoking #{t}"
      Rake::Task[t].invoke
    end
  end
  
  desc 'Install all K3 gems'
  task :install do
    k3_invoke 'install'
  end

  desc 'Copy public files from all K3 gems'
  task :copy_public do
    k3_invoke 'copy_public'
  end

  desc 'Copy migration files from all K3 gems'
  task :copy_migrations do
    k3_invoke 'copy_migrations'
  end
end