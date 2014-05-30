require "wdi/directory"

module WDI
  module Directory
    module FileAccess
      def local_file_path_of(filename)
        File.expand_path filename, WDI::Directory::PATH
      end

      def local_configuration_path
        local_file_path_of "config.json"
      end

      def configuration_from(config_uri)
        begin
          uri = URI(config_uri)
          json_configuration = ["http", "https"].include?(uri.scheme) ? uri.open.read : IO.read(config_uri)
          return JSON.parse(json_configuration, symbolize_names: true)

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

      def local_configuration
        configuration_from local_configuration_path
      end

      def save_self_locally_as(filename)
        File.open local_file_path_of(filename), "w+" do |f|
          f.write self.to_s
        end
      end

      def save_self_locally_as_configuration
        save_locally_as "config.json"
      end

      def who_is_self?
        puts self
      end
    end
  end
end
