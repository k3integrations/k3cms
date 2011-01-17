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

    def self.copy_from_gem(gem_class, relative_dir, verbose=true)
      src_dir = File.join(gem_class::Engine.root, relative_dir)
      dest_dir = File.join(Rails.root, relative_dir)
      copy_recursively(src_dir, dest_dir, verbose)
    end

    def self.symlink_from_gem(gem_class, gem_file, app_file)
      gem_file = gem_class::Engine.root + gem_file
      app_file = Rails.root             + app_file
      app_file.dirname.mkpath
      app_file.unlink if app_file.symlink?
      app_file.make_symlink(gem_file.relative_path_from(app_file)) unless app_file.exist?
    end

    # Given a glob pattern, this will create a symlink in the target app for
    # each file matching the glob in the gem's directory.  Only files will be
    # symlinked, not directories.  Example:
    # K3::FileUtils.symlink_files_from_gem K3::Blog, 'public/**/*'
    #
    def self.symlink_files_from_gem(gem_class, gem_glob)
      Dir.chdir gem_class::Engine.root do
        Dir[gem_glob].each do |file|
          gem_file = gem_class::Engine.root + file
          next unless gem_file.file?
          app_file = Rails.root             + file
          app_file.dirname.mkpath
          app_file.unlink if app_file.symlink?
          if app_file.exist?
            puts "  Skipping #{file} (#{app_file} already exists)"
          else
            puts "  Linking  #{file}"
            app_file.make_symlink(gem_file.relative_path_from(app_file.dirname))
          end
        end
      end
    end

  end
end
