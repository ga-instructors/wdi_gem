require "open-uri"
require "json"
require "thor"

require "pry"

module WDI
  module Config
    KEY_REGEX = /^[a-z.]*$/ # only lowercase words separated by periods

    def self.path
      File.expand_path("config.json", WDI::Folder::path)
    end

    def self.exists?
      File.exists?(self.path)
    end

    def self.file
      @@config ||= self.load
    end

    def self.load
      @@config = JSON.parse(IO.read(self.path), symbolize_names: true)
    end

    def self.save
      File.open(File.expand_path("config.json", WDI::Folder::path), "w+") do |f|
        f.write JSON.pretty_generate(self.file)
      end
    end

    def self.load_file(config_uri)
      begin
        uri = URI(config_uri)
        config_file = ["http", "https"].include?(uri.scheme) ? uri.open.read : IO.read(config_uri)
        @@config = self.safe_replace(JSON.parse(config_file, symbolize_names: true))
        self.save

      rescue Errno::ENOENT => e
        raise WDI::ConfigError, "No file at this path. Use 'http://' prefix if URI."
      rescue URI::InvalidURIError => e
        raise WDI::ConfigError, "Malformed URI. Could not find file at this path."
      rescue OpenURI::HTTPError => e
        raise WDI::ConfigError, "Provided URI can not be found. Ensure that the link is active."
      rescue JSON::ParserError => e
        raise WDI::ConfigError, "Provided file is not correctly formatted JSON."
      end
    end

    ############################################

    def self.get(key, key_name)
      raise WDI::ConfigError, "This key is not in the WDI config file." if key.nil?
      raise WDI::ConfigError, 
        "This key doesn't represent a property in the WDI config file. " +
        "Try `wdi config keys #{key_name}`." if key.is_a?(Hash)
      return key
    end

    def self.set(key_name, new_value)
      current_value = WDI::Config::translate(key_name)
      raise WDI::ConfigError, 
        "This key doesn't represent a property in the WDI config file. " +
        "Try `wdi config keys #{key_name}`." if current_value.is_a?(Hash)
      

      self.set_child(self.file, key_name, new_value)
      self.save
    end

    def self.set_child(key, key_name, value)
      parent, child = key_name.split(".", 2)
      if child.nil?
        key[parent.to_sym] = value
      else
        self.set_child(key[parent.to_sym], child, value)
      end
    end

    def self.keys(tree, parent_key="", key_list=[])
      raise WDI::ConfigError,
        "There are no (sub-)keys in the WDI config file that fit this criteria." unless tree.is_a?(Hash)

      tree.each_pair do |child_key, value|
        if value.is_a?(Hash)
          self.keys(value, self.append_keys(parent_key, child_key), key_list)
        else
          key_list << self.append_keys(parent_key, child_key)
        end
      end

      return key_list
    end

    ############################################

    def self.append_keys(parent, child)
      parent = (parent.nil? || parent == "") ? "" : parent.to_s + "."
      child  = (child.nil? || child == "")  ? "" : child.to_s
      parent + child
    end

    def self.translate(key, tree=self.file)
      # assume we are talking about the config tree as a whole if nil
      return tree if key.nil? 

      raise WDI::ConfigError, 
        "This key is not formatted correctly for the WDI config file." unless key =~ KEY_REGEX       
      parent, child = key.split(".", 2)
      value = tree[parent.to_sym]
      raise WDI::ConfigError, "This key is not in the WDI config file." if value.nil?

      return (child.nil? ? value : self.translate(child, value))
    end

    def self.safe_replace(config)
      JSON.recurse_proc(config) do |line|
        if line.is_a?(String)
          # so this is not REALLY safe, but should be safe enough... maybe even too restrictive
          allowed_bash_regex = /(`(echo|pwd|ls)[^\|;&]*`)/
          matched = line[allowed_bash_regex]
          unless matched.nil?
            result = eval( matched )
            line.gsub!( allowed_bash_regex, result.chomp ) #unless result.nil?
          end
        end
      end

      return config
    end
  end
end