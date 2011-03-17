require 'fileutils'

module K3
  class FileUtils
    # TODO: reuse some code from Rails generators so that we can get for free: check for identical, offer to give a diff or overwrite, etc.
    def self.copy_file(src_file, dest_file, verbose=true)
      file = src_file
      copy = true
      differs = false
      if File.exists?(dest_file)
        if ::FileUtils.compare_file(src_file, dest_file)
          copy = false
        else
          print "  WARNING!!! File #{file} already exists and has been modified. Overwrite? [y/n] "
          if (copy = $stdin.gets.downcase[0] == 'y')
            Pathname.new(dest_file).unlink
          end
        end
      end
      if copy
        puts "  Copying file #{file}" if verbose
        ::FileUtils.mkdir_p(File.dirname(dest_file))
        ::FileUtils.copy(src_file, dest_file)
      elsif ::FileUtils.compare_file(src_file, dest_file)
        puts "  Identical: #{file}" if verbose
      end
    end

    def self.copy_recursively(src_dir, dest_dir, verbose=true)
      src_files = Dir[File.join(src_dir, '**', '*')]
      src_files.each do |src_file|
        next if ! File.file?(src_file)
        file_rel = src_file.sub(/^#{src_dir}#{File::SEPARATOR}/, '')
        dest_file = File.join(dest_dir, file_rel)
        copy_file src_file, dest_file, verbose
      end
    end

    def self.copy_from_gem(gem_class, relative_dir, verbose=true)
      src_dir = File.join(gem_class::Engine.root, relative_dir)
      dest_dir = File.join(Rails.root, relative_dir)
      copy_recursively(src_dir, dest_dir, verbose)
    end

    def self.copy_file_from_gem(gem_class, gem_file, app_file, verbose=true)
      gem_file = gem_class::Engine.root + gem_file
      app_file = Rails.root             + app_file
      app_file.dirname.mkpath
      copy_file(gem_file, app_file, verbose)
    end

    def self.symlink_from_gem(gem_class, gem_file, app_file)
      gem_file = gem_class::Engine.root + gem_file
      app_file = Rails.root             + app_file
      app_file.dirname.mkpath
      app_file.unlink if app_file.symlink?
      app_file.make_symlink(gem_file.relative_path_from(app_file.dirname)) unless app_file.exist?
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
