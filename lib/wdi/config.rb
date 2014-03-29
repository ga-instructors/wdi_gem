require "open-uri"
require "json"

require "pry"

module WDI
  module Config
    def self.load(config_uri)
      begin
        uri = URI(config_uri)
        config_file = ["http", "https"].include?(uri.scheme) ? uri.open.read : IO.read(config_uri)
        @@config = self.safe_replace(JSON.parse(config_file, symbolize_names: true))
        
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

    def self.file
      @@config ||= self.load(WDI::DEFAULT_CONFIG_FILE)
    end

    def self.safe_replace(config)
      JSON.recurse_proc(config) do |line|
        if line.class == String
          # so this is not REALLY safe, but should be safe enough... maybe even too restrictive
          allowed_bash_regex = /(`(echo|pwd|ls)[^\|;&]*`)/
          
          result = eval( line[allowed_bash_regex] )
          line.gsub!( allowed_bash_regex, result.chomp ) unless result.nil?
        end
      end

      return config
    end
  end
end