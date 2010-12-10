require 'fileutils'

module K3
  class FileUtils
    def self.copy_recursively(src_dir, dest_dir, verbose=true)
      src_files = Dir[File.join(src_dir, '**', '*')]
      src_files.each do |src|
        next if ! File.file?(src)
        file = src.sub(/^#{src_dir}#{File::SEPARATOR}/, '')
        dest = File.join(dest_dir, file)
        copy = true
        if File.exists?(dest)
          print "  WARNING!!! File #{file} already exists. Overwrite? [y/n] "
          if (copy = $stdin.gets.downcase[0] == 'y')
            Pathname.new(dest).unlink
          end
        end
        if copy
          puts "  Copying file #{file}" if verbose
          ::FileUtils.mkdir_p(File.dirname(dest))
          ::FileUtils.copy(src, dest)
        elsif ! ::FileUtils.compare_file(src,dest)
          puts "  WARNING!!! File #{file} has been modified, not copying" if verbose
        end
      end
    end

    def self.symlink_from_gem(gem_class, gem_file, app_file)
      gem_file = gem_class::Engine.root + gem_file
      app_file = Rails.root             + app_file
      app_file.dirname.mkpath
      Pathname.new(app_file).make_symlink(gem_file.relative_path_from(app_file)) unless app_file.exist?
    end

    def self.copy_from_gem(gem_class, relative_dir, verbose=true)
      src_dir = File.join(gem_class::Engine.root, relative_dir)
      dest_dir = File.join(Rails.root, relative_dir)
      copy_recursively(src_dir, dest_dir, verbose)
    end
  end
end
