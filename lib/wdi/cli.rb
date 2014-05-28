require "wdi"
require "wdi/folder"
require "wdi/config"
require "thor"

module WDI
  module CLI
    class Config < Thor
      desc "set", "set a value in the WDI config file"
      def set(key, value)
        begin
          WDI::Config::set(key, value)
          say "The property '#{key}' in the WDI config file has been set to '#{value}'.", :green
        rescue WDI::ConfigError => e
          say e.message, :red
        end
      end

      desc "get", "get a value from the WDI config file"
      def get(key)
        begin
          say WDI::Config::get(key)
        rescue WDI::ConfigError => e
          say e.message, :red
        end
      end

      desc "add", "adds new properties or adds values to an existing property as a list"
      method_option :force,
                    aliases: ["-f"],
                    default: false,
                    desc:    "Skip confirmation prompt when property already exists"
      def add(key, *values)
        begin
          if WDI::Config::has_property?(key)
            if values != []
              do_it = options[:force] ? true : yes?("This property already exists. Add value(s) to it? (y/n)", :yellow)
              if do_it
                WDI::Config::add(key, values)
                say "The property '#{key}' has been added to the WDI config file.", :green
              end
            else
              say "The property '#{key}' already exists in the WDI config file!", :green
            end
          else
            WDI::Config::add(key, values)
            say "The property '#{key}' has been added to the WDI config file.", :green
          end
        rescue WDI::ConfigError => e
          say e.message, :red
        end
      end

      desc "remove", "deletes a key from the config file"
      method_option :force,
                    aliases: ["-f"],
                    default: false,
                    desc:    "Force key's removal, if it exists, without prompting the user for confirmation."
      def remove(key)
        begin
          if WDI::Config::has_property?(key)
            do_it = options[:force] ? true : yes?("This will remove the property '#{key}.' Continue? (y/n)", :yellow)
            if do_it
              WDI::Config::remove(key)
              say "The property '#{key}' has been removed from the WDI config file.", :green
            end
          else
            say "The property '#{key}' is not in the WDI config file.", :red
          end
        rescue WDI::ConfigError => e
          say e.message, :red
        end
      end

      desc "keys", "list the properties in the WDI config file"
      def keys(key=nil)
        begin
          say WDI::Config::properties(key).join("\n")
        rescue WDI::ConfigError => e
          say e.message, :red
        end
      end
    end

    class Files < Thor
      desc "add", "add a new file to the WDI files directory"
      def add(filename)
        begin
          unless WDI::Folder::Files.exists(filename)
            WDI::Folder::Files.create(filename)
          end
        rescue WDI::ConfigError => e
          say e.message, :red
        end
      end
    end

    class Wdi < Thor
      #class_option :version, alias: "-v", type: :boolean

      desc "version", "get current WDI tool version"
      def version
        say WDI::VERSION
      end

      desc "init", "initialize a new WDI directory at ~/.wdi"
      method_option :load, 
                    aliases: ["-l"],
                    default: WDI::DEFAULT_CONFIG_FILE, 
                    desc:    "Load the WDI config(.json) from a local file or URI path."
      method_option :force,
                    aliases: ["-f"],
                    default: false,
                    desc:    "Force overwrite of the current WDI directory, if it exists."
      def init
        begin
          WDI::Folder::create_with_config(options[:force], options[:load])
          say "The .wdi folder and config file have been created.", :green
        rescue WDI::ConfigError, WDI::FolderError => e
          say e.message, :red
        end
      end

      desc "config SUBCOMMAND ...ARGS", "interact with the WDI config file"
      subcommand "config", WDI::CLI::Config

      desc "files SUBCOMMAND ...ARGS", "interact with the WDI files directory"
      subcommand "files", WDI::CLI::Files
    end
  end
end