require "wdi/directory"

require "fileutils"
require "json"

module WDI
  module Directory
    class FileAccessor
      class << self
        def local_file_path_of(filename)
          File.expand_path filename, PATH
        end

        def local_configuration_path
          local_file_path_of CONF
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

        def local_config
          configuration_from local_configuration_path
        end

        def save_locally_as(filename, contents)
          File.open local_file_path_of(filename), "w+" do |f|
            f.write contents.to_s
          end
        end

        def save_locally_as_config(contents)
          save_locally_as CONF, contents.to_json
        end

        # def who_is_self?
        #   puts self
        # end
      end
    end
  end
end
