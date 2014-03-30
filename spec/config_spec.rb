require "spec_helper"

describe WDI::Config do
  
  describe WDI::Config::File do # namespacing weirdness...
    config_json_contents = <<-JSON_CONTENTS
    {
      \"name\": \"`whoami`\",
      \"base\": \"`echo $HOME`/dev/wdi\",
      \"repos\": {
        \"classes\": {
          \"current\": \"`echo $HOME`/dev/wdi/class_name\"
        }
      },
      \"go\": {
        \"repo\": \":repos.classes.current\",
        \"pattern\": \"/\\1/\\2/:name\"
      }
    }
    JSON_CONTENTS

    let!(:config) {WDI::Config::File.new(config_json_contents)}

    describe "#to_s" do
      it "returns a string version of the contents" do
        expect(config.to_s).to eql(config_json_contents)
      end
    end
  end

end