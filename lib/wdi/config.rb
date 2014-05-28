require "open-uri"
require "json"
require "thor"

require "pry"

module WDI
  module Config
    KEY_REGEX          = /^[a-z.]*$/ # only lowercase words separated by periods
    VALUE_AS_KEY_REGEX = /:[a-z._]+/ # a value containing at least one word prefixed by ':'
    ALLOWED_BASH_REGEX = /(`(echo|pwd|ls|whoami)[^\|;&]*`)/
    # COMMAND REGEX
    # property regex
    # value as property (reference) regex

    ##############################################################
    class ConfigFile
      attr_reader :pairs

      def initialize(json_configuration)
        config = JSON.parse(json_configuration, symbolize_names: true)

        @pairs = {}
        recursive_build_pairs_from config
        ensure_format_of_pairs
      end

      def has_key?(key)
        key = translate_incoming(key)
        @pairs.key?(key)
      end

      def value_at(key)
        key = translate_incoming(key)
        
        if @pairs.key?(key)
          if @pairs[key].is_a? Array
            return @pairs[key].map {|value| retrieve_value_with_references(value) }
          else
            return retrieve_value_with_references(@pairs[key])
          end
        elsif keys_with_prefix(key)
          raise WDI::ConfigError, 
            "This key doesn't represent a property in the WDI config file. " +
            "Try `wdi config keys #{key}`."
        else
          return false
        end
      end

      def keys_with_value(value)
        key_list = @pairs.select {|k,v| v == value}.keys
        key_list.count == 0 ? false : key_list.map{|k| translate_outgoing(k)}
      end

      def set_key_value(key, value)
        key = translate_incoming(key)

        raise WDI::ConfigError,
            "This key is not in the WDI config file." unless @pairs.key?(key)
        raise WDI::ConfigError,
            "This value is not formatted correctly for the WDI config file." unless value.is_a?(String)
        disallow_bad_references_in value
        @pairs[key] = value
      end

      def add_key_value(key, value="")
        key = translate_incoming(key)
        disallow_bad_references_in value

        if has_key?(key)
          if @pairs[key] == value || (@pairs[key].is_a?(Array) && @pairs[key].include?(value))
            raise WDI::ConfigError, 
              "The property '#{key}' already contains the value '#{value}'. Can not add duplicates."
          end
          if @pairs[key].is_a? Array
            @pairs[key] << value unless value == ""
          elsif @pairs[key] == ""
            @pairs[key] = value
          else
            @pairs[key] = [@pairs[key],value] unless value == ""
          end
        else
          @pairs[key] = value
        end
        return @pairs[key]
      end

      def remove_property(property)
        property = translate_incoming(property)
        unless has_key?(property)
          raise WDI::ConfigError,
            "This key is not in the WDI config file. Try `wdi config keys #{property}`."
        end
        @pairs.delete property
      end

      def keys
        @pairs.keys.map{|k| translate_outgoing(k)}
      end

      def keys_with_prefix(prefix=nil)
        return keys if prefix.nil?
        prefix = translate_outgoing(translate_incoming(prefix)) # force correct string format
        key_list = keys.select{|k| (k =~ Regexp.new(prefix)) == 0 }
        key_list.count == 0 ? false : key_list
      end

      def to_h
        result = {}

        keys.each do |key|
          add_child_node(result, key, @pairs[translate_incoming(key)])
        end

        return result
      end

      def to_json
        JSON.pretty_generate(self.to_h)
      end

      def to_s
        @pairs.to_s
      end

    private
      def translate_incoming(key)
        if key.is_a? String
          key.gsub(/\./, "_").to_sym
        elsif key.is_a? Symbol
          key
        else
          raise WDI::ConfigError, 
            "This property is not formatted correctly for the WDI config file."
        end
      end

      def interpolate_commands_in(value)
        value.gsub(ALLOWED_BASH_REGEX) do |command|
          eval(command).chomp
        end
      end

      def translate_outgoing(key)
        key.to_s.gsub(/_/,".")
      end

      def retrieve_value_with_references(value)
        value = interpolate_commands_in value
        check_value = disallow_bad_references_in value
        
        return value if (check_value =~ VALUE_AS_KEY_REGEX).nil?
        check_value.gsub(VALUE_AS_KEY_REGEX) {|reference| value_at(reference[1..-1])}
      end

      def ensure_format_of_pairs
        pairs.each_pair do |key, value|
          key = translate_outgoing(key)

          if (key =~ KEY_REGEX).nil? || key[0] == "." || key[-1] == "."
            raise WDI::ConfigError, 
              "This property is not formatted correctly for the WDI config file."
          end
          
          if !(value.is_a?(String) || value.is_a?(Array))
            raise WDI::ConfigError,
              "This value is not formatted correctly for the WDI config file " + \
              "(must be a string or an array of strings)."
          else
            disallow_bad_references_in value
          end
        end
      end

      def disallow_bad_references_in(value)
        if value.is_a? Array
          value.each do |v|
            check_value = v.gsub(VALUE_AS_KEY_REGEX) do |reference|
              translate_outgoing(reference) # only translate to dots if matches reference
            end

            check_value.scan(VALUE_AS_KEY_REGEX) do |reference|
              unless has_key?(reference[1..-1])
                raise WDI::ConfigError,
                  "This value is not formatted correctly for the WDI config file " + \
                  "(malformed reference)."
              end
            end
          end
        else
          check_value = value.gsub(VALUE_AS_KEY_REGEX) do |reference|
            translate_outgoing(reference) # only translate to dots if matches reference
          end

          check_value.scan(VALUE_AS_KEY_REGEX) do |reference|
            unless has_key?(reference[1..-1])
              raise WDI::ConfigError,
                "This value is not formatted correctly for the WDI config file " + \
                "(malformed reference)."
            end
          end
        end
      end

      def recursive_build_pairs_from(tree, parent_key="")
        tree.each_pair do |child_key, value|
          if value.is_a?(Hash)
            recursive_build_pairs_from(value, append_keys(parent_key, child_key))
          else
            @pairs[append_keys(parent_key, child_key).to_sym] = value
          end
        end
      end

      def add_child_node(node, key, value)
        parent, child = key.split(".", 2)

        if child.nil?
          node[parent.to_sym] = value
        else
          node[parent.to_sym] = {} if node[parent.to_sym].nil?
          add_child_node(node[parent.to_sym], child, value)
        end
      end

      def append_keys(parent, child)
        parent = (parent.nil? || parent == "") ? "" : parent.to_s + "_"
        child  = (child.nil? || child == "")  ? "" : child.to_s
        parent + child
      end
    end
    ###############################################################

    def self.path
      File.expand_path("config.json", WDI::Folder::path)
    end

    def self.exists?
      File.exists?(self.path)
    end

    def self.config
      @@config ||= self.load_local_configuration
    end

    def self.load_local_configuration
      @@config = WDI::Config::ConfigFile.new(IO.read(self.path))
    end

    def self.load_configuration_from(config_uri)
      begin
        uri = URI(config_uri)
        config_file = ["http", "https"].include?(uri.scheme) ? uri.open.read : IO.read(config_uri)
        @@config = WDI::Config::ConfigFile.new config_file
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

    def self.save
      File.open(File.expand_path("config.json", WDI::Folder::path), "w+") do |f|
        f.write self.config.to_json
      end
    end

    ###############################################################
    ## WRAPPER MODULE METHODS

    def self.create(config_uri)
      config_uri.nil? ? self.load_local_configuration : self.load_configuration_from(config_uri)
    end

    def self.get(property)
      self.config.value_at property
    end

    def self.set(property, value)
      self.config.set_key_value property, value
      self.save
    end

    def self.add(property, values)
      values = (values == [] ? [""] : (values.is_a?(Array) ? values : [values]))
      binding.pry
      values.each {|value| self.config.add_key_value(property, value)}
      self.save
    end

    def self.remove(property)
      self.config.remove_property property
      self.save
    end

    def self.properties(prefix=nil)
      self.config.keys_with_prefix prefix
    end

    def self.has_property?(property)
      self.config.has_key? property
    end

  end
end