require "fileutils"
require "json"

module WDI
  module Folder
    WDI_FILES_PATH = File.expand_path(".wdi/data", "~")

    class Files
      def self.exists(name)
        files = WDI::Config.get "wdi.files"
        unless files
          WDI::Config.add("wdi.files",[])
          return false
        end

        files.include? name
      end

      def self.create(name)
        FileUtils.touch(File.expand_path(name, WDI_FILES_PATH))
        WDI::Config.add("wdi.files",name)
      end

      def self.write_to(name, io_stream)
        File.open(name, "w") do |f|
          text = io_stream.write
          f.read text
        end
      end

      def self.remove(name)

      end
    end


    def self.path
      File.expand_path(".wdi", "~")
    end

    def self.exists?
      File.exists?(self.path)
    end

    def self.create(remove_current_directory)
      self.remove! if remove_current_directory

      raise WDI::FolderError, \
        "The .wdi folder already exists. Either remove it to initialize anew, " + \
        "or use `wdi config` to edit the config file."  if self.exists?

      Dir.mkdir self.path
      Dir.mkdir WDI_FILES_PATH
    end

    def self.create_with_config(remove_current_directory, file)
      self.create(remove_current_directory)
      WDI::Config::create(file)
    end

    def self.remove!
      FileUtils.rm_rf(self.path) if self.exists?
    end
  end
end
