require 'fileutils'

module K3
  class FileUtils
    def self.copy_recursively(src_dir,dest_dir,verbose=true)
      src_files = Dir[File.join(src_dir,'**','*')]
      src_files.each do |src|
        next if ! File.file?(src)
        file = src.sub(/^#{src_dir}#{File::SEPARATOR}/,'')
        dest = File.join(dest_dir,file)
        if ! File.exists?(dest)
          puts "  Copying file #{file}" if verbose
          ::FileUtils.mkdir_p(File.dirname(dest))
          ::FileUtils.copy(src,dest)
        elsif ! ::FileUtils.compare_file(src,dest)
          puts "  WARNING!!! File #{file} has been modified, not copying" if verbose
        end
      end
    end
    
    def self.copy_from_gem(gem_class,relative_dir,verbose=true)
      src_dir = File.join(gem_class::Engine.root,relative_dir)
      dest_dir = File.join(Rails.root,relative_dir)
      copy_recursively(src_dir,dest_dir,verbose)
    end
  end
end