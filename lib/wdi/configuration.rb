require "wdi"
require "wdi/directory/file_access"

require "delegate"
require "open-uri"
require "json"
require "thor"

require "pry"

module WDI
  module Configuration
    # KEY_REGEX          = /^[a-z]{2,}(?:_*[a-z]{2,})*$/  # only lowercase words of 2 or more letters, separated by underscores
    # VALUE_AS_KEY_REGEX = /:[a-z]{2,}(?:_*[a-z]{2,})*/   # same formatting as a key (but not for whole value), prefixed with a colon
    ALLOWED_BASH_REGEX = /(`(echo|pwd|ls|whoami)[^\|;&]*`)/
    # TODO PJ: problem with the regexes: they don't allow for key names with numbers or spaces, such as "WDI NYC Sep 2014"

    module ConfigMethods
      # def respond_to?(name, include_private = false)
      #   return true if key?(name.to_s) || key?(name.to_sym)
      #   super
      # end
      #
      # def method_missing(name, *args)
      #   return self[name.to_s] if key?(name.to_s)
      #   return self[name.to_sym] if key?(name.to_sym)
      #   super
      # end
    end

    class ConfigHash < SimpleDelegator
      include ConfigMethods

    end

    class ConfigFile
      extend WDI::Directory::FileAccess

      @@hash = self.local_configuration

      class << self
        @@hash.each_key do |key|
          define_method(key) do
            value = @@hash[key]
            if value.class == Hash
              return ConfigHash.new(value)
            else
              return interpolate_commands_in(value)
            end
          end
        end
      end

      private

      def self.interpolate_commands_in(value)
        value.gsub(ALLOWED_BASH_REGEX) do |command|
          eval(command).chomp
        end
      end
    end

    # class ConfigFile ###########################################################
    #   attr_reader :pairs
    #
    #   def initialize(json_configuration)
    #     config = JSON.parse(json_configuration, symbolize_names: true)
    #
    #     @pairs = {}
    #     recursive_build_pairs_from config
    #     ensure_format_of_pairs
    #   end
    #
    #   def properties
    #     pairs.keys
    #   end
    #
    #   def properties_with_prefix(prefix=nil)
    #     properties.select {|property| (property =~ Regexp.new(prefix.to_s)) == 0 }
    #   end
    #
    #   def properties_with_value(value)
    #     pairs.select {|k,v| v == value}.keys
    #   end
    #
    #   def has_property?(property)
    #     ensured_has_property? ensure_is_symbol(property)
    #   end
    #
    #   def value_of(property)
    #     ensured_value_of ensure_is_symbol(property)
    #   end
    #
    #   def set_property(property, value)
    #     ensured_set_property ensure_is_symbol(property), value
    #   end
    #
    #   def add_property(property, value="")
    #     ensured_add_property ensure_is_symbol(property), value
    #   end
    #
    #   def remove_property(property)
    #     ensured_remove_property ensure_is_symbol(property)
    #   end
    #
    #   def to_h
    #     result = {}
    #
    #     properties.each do |property|
    #       add_child_node(result, property, @pairs[property])
    #     end
    #
    #     return result
    #   end
    #
    #   def to_json
    #     JSON.pretty_generate(self.to_h)
    #   end
    #
    #   def to_s
    #     pairs.to_s
    #   end
    #
    #   private ##################################################################
    #
    #   def ensured_has_property?(property)
    #     pairs.key?(property)
    #   end
    #
    #   def ensured_value_of(property)
    #     if ensured_has_property? property
    #       if pairs[property].is_a? Array
    #         return pairs[property].map {|value| retrieve_value_with_references(value) }
    #       else
    #         return retrieve_value_with_references(pairs[property])
    #       end
    #     end
    #   end
    #
    #   def ensured_set_property(property, value)
    #     raise WDI::ConfigError,
    #         "This key is not in the WDI config file." unless @pairs.key?(property)
    #     raise WDI::ConfigError,
    #         "This value is not formatted correctly for the WDI config file." unless value.is_a?(String)
    #     disallow_bad_references_in value
    #     pairs[property] = value
    #   end
    #
    #   def ensured_add_property(property, value)
    #     disallow_bad_references_in value
    #
    #     if ensured_has_property? property
    #       if pairs[property] == value || (pairs[property].is_a?(Array) && pairs[property].include?(value))
    #         raise WDI::ConfigError,
    #           "The property '#{property}' already contains the value '#{value}'. Can not add duplicates."
    #       end
    #       if pairs[property].is_a? Array
    #         pairs[property] << value unless value == ""
    #       elsif pairs[property] == ""
    #         pairs[property] = value
    #       else
    #         pairs[property] = [pairs[property],value] unless value == ""
    #       end
    #     else
    #       pairs[property] = value
    #     end
    #
    #     return pairs[property]
    #   end
    #
    #   def ensured_remove_property(property)
    #     unless has_property?(property)
    #       raise WDI::ConfigError,
    #         "This key is not in the WDI config file. Try `wdi config keys #{property}`."
    #     end
    #     pairs.delete property
    #   end
    #
    #   def ensure_is_symbol(property)
    #     if property.is_a? Symbol
    #       return property
    #     elsif property.is_a? String
    #       return property.to_sym
    #     else
    #       raise WDI::ConfigError,
    #         "This property is not formatted correctly for the WDI config file."
    #     end
    #   end
    #
    #   def interpolate_commands_in(value)
    #     value.gsub(ALLOWED_BASH_REGEX) do |command|
    #       eval(command).chomp
    #     end
    #   end
    #
    #   def retrieve_value_with_references(value)
    #     value = interpolate_commands_in value
    #
    #     return value if (value =~ VALUE_AS_KEY_REGEX).nil?
    #     value.gsub(VALUE_AS_KEY_REGEX) {|reference| value_of(reference[1..-1])}
    #   end
    #
    #   def ensure_format_of_pairs
    #     pairs.each_pair do |key, value|
    #       if (key =~ KEY_REGEX).nil?
    #         raise WDI::ConfigError,
    #           "This property is not formatted correctly for the WDI config file."
    #       end
    #
    #       if (value.is_a?(String) || value.is_a?(Array))
    #         disallow_bad_references_in value
    #       else
    #         raise WDI::ConfigError,
    #           "This value is not formatted correctly for the WDI config file " + \
    #           "(must be a string or an array of strings)."
    #       end
    #     end
    #   end
    #
    #   def disallow_bad_references_in(value)
    #     if value.is_a? Array
    #       value.each do |value_member|
    #         value_member.scan(VALUE_AS_KEY_REGEX) do |reference|
    #           unless has_property?(reference[1..-1])
    #             raise WDI::ConfigError,
    #               "This value is not formatted correctly for the WDI config file " + \
    #               "(malformed reference)."
    #           end
    #         end
    #       end
    #     else
    #       value.scan(VALUE_AS_KEY_REGEX) do |reference|
    #         unless has_property?(reference[1..-1])
    #           raise WDI::ConfigError,
    #             "This value is not formatted correctly for the WDI config file " + \
    #             "(malformed reference)."
    #         end
    #       end
    #     end
    #   end
    #
    #   def recursive_build_pairs_from(tree, parent_key="")
    #     tree.each_pair do |child_key, value|
    #       if value.is_a?(Hash)
    #         recursive_build_pairs_from(value, append_keys(parent_key, child_key))
    #       else
    #         pairs[append_keys(parent_key, child_key).to_sym] = value
    #       end
    #     end
    #   end
    #
    #   def add_child_node(node, key, value)
    #     parent, child = key.to_s.split("_", 2)
    #
    #     if child.nil?
    #       node[parent.to_sym] = value
    #     else
    #       node[parent.to_sym] = {} if node[parent.to_sym].nil?
    #       add_child_node(node[parent.to_sym], child, value)
    #     end
    #   end
    #
    #   def append_keys(parent, child)
    #     parent = (parent.nil? || parent == "") ? "" : parent.to_s + "_"
    #     child  = (child.nil? || child == "")   ? "" : child.to_s
    #     parent + child
    #   end
    # end
    # ###############################################################





    # def self.config
    #   @@config ||= self.load_local_configuration
    # end
    #
    # def self.load_local_configuration
    #   @@config = WDI::Config::ConfigFile.new(IO.read(self.path))
    # end
    #
    # def self.load_configuration_from(config_uri)
    #   begin
    #     uri = URI(config_uri)
    #     config_file = ["http", "https"].include?(uri.scheme) ? uri.open.read : IO.read(config_uri)
    #     @@config = WDI::Config::ConfigFile.new config_file
    #     self.save
    #
    #   rescue Errno::ENOENT => e
    #     raise WDI::ConfigError, "No file at this path. Use 'http://' prefix if URI."
    #   rescue URI::InvalidURIError => e
    #     raise WDI::ConfigError, "Malformed URI. Could not find file at this path."
    #   rescue OpenURI::HTTPError => e
    #     raise WDI::ConfigError, "Provided URI can not be found. Ensure that the link is active."
    #   rescue JSON::ParserError => e
    #     raise WDI::ConfigError, "Provided file is not correctly formatted JSON."
    #   end
    # end
    #
    # def self.save
    #   File.open(File.expand_path("config.json", WDI::Folder::path), "w+") do |f|
    #     f.write self.config.to_json
    #   end
    # end
    #
    # ###############################################################
    # ## WRAPPER MODULE METHODS
    #
    # def self.create(config_uri)
    #   config_uri.nil? ? self.load_local_configuration : self.load_configuration_from(config_uri)
    # end
    #
    # def self.get(property)
    #   self.config.value_of property
    # end
    #
    # def self.set(property, value)
    #   self.config.set_key_value property, value
    #   self.save
    # end
    #
    # def self.add(property, values)
    #   values = (values == [] ? [""] : (values.is_a?(Array) ? values : [values]))
    #   values.each {|value| self.config.add_key_value(property, value)}
    #   self.save
    # end
    #
    # def self.remove(property)
    #   self.config.remove_property property
    #   self.save
    # end
    #
    # def self.properties(prefix=nil)
    #   self.config.keys_with_prefix prefix
    # end
    #
    # def self.has_property?(property)
    #   self.config.has_property? property
    # end

  end
end
