require "spec_helper"

describe WDI::Config do
  describe WDI::Config::ConfigFile do # namespacing weirdness...
    config_json_contents_with_interpolation = <<-JSON_CONTENTS
    {
      "name": "`whoami`",
      "base": "`echo $HOME`/dev/wdi",
      "repos": {
        "classes": {
          "current": "`echo $HOME`/dev/wdi/class_name"
        }
      },
      "go": {
        "repo": ":repos_classes_current",
        "pattern": "/w%02d/d0%d/:name"
      },
      "wdi": {
        "files": [
          "curriculum.json"
        ],
        "commands": [
          "go"
        ]
      }
    }
    JSON_CONTENTS

    config_json_contents = <<-JSON_CONTENTS
    {
      "name": "philip",
      "base": "/Users/philip/dev/wdi",
      "repos": {
        "classes": {
          "current": "/Users/philip/dev/wdi/class_name"
        }
      },
      "go": {
        "repo": ":repos_classes_current",
        "pattern": "/w%02d/d0%d/:name"
      },
      "wdi": {
        "files": [
          "curriculum.json"
        ],
        "commands": [
          "go"
        ]
      }
    }
    JSON_CONTENTS

    correct_config_pairs = {
      name:         "`whoami`",
      base:         "`echo $HOME`/dev/wdi",
      repos_classes_current: "`echo $HOME`/dev/wdi/class_name",
      go_repo:      ":repos_classes_current",
      go_pattern:   "/w%02d/d0%d/:name",
      wdi_files:    ["curriculum.json"],
      wdi_commands: ["go"]
    }

    correct_config_properties = [:name,:base,:repos_classes_current,:go_repo,:go_pattern,:wdi_files,:wdi_commands]

    correct_config_hash = {
      name: "`whoami`",
      base: "`echo $HOME`/dev/wdi",
      repos: {
        classes: {
          current: "`echo $HOME`/dev/wdi/class_name"
        }
      },
      go: {
        repo:    ":repos_classes_current",
        pattern: "/w%02d/d0%d/:name"
      },
      wdi: {
        files:    ["curriculum.json"],
        commands: ["go"]
      }
    }

    describe "#initialize" do
      it "raises an error if properties aren't formatted for the config to work" do
        expect {WDI::Config::ConfigFile.new('{"name1":"pj"}')}.to raise_error
        expect {WDI::Config::ConfigFile.new('{"name_":"pj"}')}.to raise_error
        expect {WDI::Config::ConfigFile.new('{"_name":"pj"}')}.to raise_error
        expect {WDI::Config::ConfigFile.new('{"n":    "pj"}')}.to raise_error
      end

      it "allows bash commands in the values" do
        expect(WDI::Config::ConfigFile.new(config_json_contents_with_interpolation).pairs).to \
          eql(correct_config_pairs)
      end

      it "does not allow string values to have colon-prefixed words unless they reference properties" do
        expect {WDI::Config::ConfigFile.new('{"name":":not_name"}')}.to raise_error
      end
    end

    let!(:config) {WDI::Config::ConfigFile.new(config_json_contents)}

    describe "#properties" do
        it {} # TODO
    end

    describe "#properties_with_prefix" do
      it "returns the properties with the given prefix" do
        expect(config.properties_with_prefix("go")).to eql([:go_repo,:go_pattern])
      end

      it "returns the property itself if the prefix is a property" do
        expect(config.properties_with_prefix("go_repo")).to eql([:go_repo])
      end

      it "returns an empty array when the property is not present" do
        expect(config.properties_with_prefix("not_a_property")).to eql([])
      end

      it "returns all properties when given no prefix" do
        expect(config.properties_with_prefix).to match_array(correct_config_properties)
      end
    end

    describe "#properties_with_value" do
      it "returns the properties at the given value (as a symbol)" do
        expect(config.properties_with_value("philip")).to eql([:name])
      end

      it "returns the properties with dots replaced by underscores" do
        expect(config.properties_with_value("/Users/philip/dev/wdi/class_name")).to \
          eql([:repos_classes_current])
      end

      it "returns multiple properties if necessary" do
        config.add_property("repos_instructors_current", "/Users/philip/dev/wdi/class_name")
        expect(config.properties_with_value("/Users/philip/dev/wdi/class_name")).to \
          eql([:repos_classes_current,:repos_instructors_current])
      end

      it "returns an empty array if the value is not present" do
        expect(config.properties_with_value("not_a_value")).to eql([])
      end
    end

    describe "#has_property?" do
      it "returns true if the property exists" do
        expect(config.has_property?("name")).to be_true
      end

      it "works when property is given in symbol format" do
        expect(config.has_property?(:repos_classes_current)).to be_true
      end

      it "returns false if the property doesn't exist" do
        expect(config.has_property?("nom")).to be_false
      end

      it "returns false if the property isn't a property" do
        expect(config.has_property?("repos")).to be_false
      end

      it "returns true if the property exists and is an array" do
        config.add_property("file","file1")
        config.add_property("file","file2")
        expect(config.has_property?("file")).to be_true
      end
    end

    describe "#value_of" do
      it "returns the value at the given property (as a symbol)" do
        expect(config.value_of(:name)).to eql("philip")
      end

      it "returns the value at the given property (as a string)" do
        expect(config.value_of("name")).to eql("philip")
      end

      it "works with property strings appropriately" do
        expect(config.value_of("repos_classes_current")).to \
          eql("/Users/philip/dev/wdi/class_name")
      end

      it "works with property symbols appropriately" do
        expect(config.value_of(:repos_classes_current)).to \
          eql("/Users/philip/dev/wdi/class_name")
      end

      it "raises an error when the property exists but is not a leaf node", :broken => true do
        expect {config.value_of("repos_classes")}.to raise_error
        expect {config.value_of(:repos_classes)}.to raise_error
      end

      it "returns an empty array when the property is not in the config file" do
        expect(config.value_of(:not_a_property)).to eql(nil)
      end

      context "the value is a property reference, ie starts with a colon" do
        it "returns the referenced property value" do
          expect(config.value_of("go_repo")).to \
            eql("/Users/philip/dev/wdi/class_name")
        end

        it "works with either format for the reference" do
          config.set_property "go_repo", ":repos_classes_current"
          expect(config.value_of("go_repo")).to \
            eql("/Users/philip/dev/wdi/class_name")
        end

        it "interpolates if the reference is in the value" do
          expect(config.value_of("go_pattern")).to eql("/w%02d/d0%d/philip")
        end

        it "raises an error when the referenced property does not exist", :broken => true do
          allow(config).to receive(:disallow_bad_references_in) # not totally secure in this working...
          config.set_property "go_repo", ":not_a_value"

          expect {config.value_of("go_repo")}.to raise_error
        end
      end

      context "the value contains an allowed bash command" do
        let!(:config) {WDI::Config::ConfigFile.new(config_json_contents_with_interpolation)}

        it "returns the value with the command result interpolated" do
          expect(config.value_of("base")).to eql((`echo $HOME`).chomp + "/dev/wdi")
        end

        it "works even when it was referenced" do
          expect(config.value_of("go_repo")).to eql((`echo $HOME`).chomp + "/dev/wdi/class_name")
        end
      end
    end

    describe "#set_property" do
      it "updates the value at the given property" do
        config.set_property "name", "pj"
        expect(config.value_of("name")).to eql("pj")
      end

      it "works when property is given in symbol format" do
        config.set_property :repos_classes_current, "/"
        expect(config.value_of("repos_classes_current")).to eql("/")
      end

      it "raises an error if the property doesn't exist" do
        expect {config.set_property "nom", "pj"}.to raise_error
      end

      it "raises an error if the value isn't a string" do
        expect {config.set_property "name", :pj}.to raise_error
      end

      context "with string values that have colon-prefixed words" do
        it "does not allow them unless they reference properties" do
          expect {config.set_property "name", "hello i am :not_name"}.to raise_error
        end

        it "allows them when they reference properties" do
          expect {config.set_property "name", "hello i am :name"}.not_to raise_error
        end
      end
    end

    describe "#add_property" do
      it "adds a new property with the given value" do
        config.add_property("repos_instructors_current", "/Users/philip/dev/wdi/class_name")
        expect(config.value_of("repos_instructors_current")).to eql("/Users/philip/dev/wdi/class_name")
      end

      context "when a property is given but not a value" do
        it "does not effect a property that already exists" do
          config.add_property("name")
          expect(config.value_of("name")).to eql("philip")
        end

        it "creates the property and sets it to an empty string if it does not exist" do
          config.add_property("new_property")
          expect(config.value_of("new_property")).to eql("")
        end
      end

      context "when the given property already exists and is not an array" do
        it "turns the property into an array and pushes the new value on to it" do
          config.add_property("name", "pj")
          expect(config.value_of("name")).to match_array(["philip","pj"])
        end

        it "does not turn the property into an array if the value is not given", :unnecessary => true do
          config.add_property("name")
          expect(config.value_of("name")).to eql("philip")
        end

        it "throws an error if the value exists in the array already" do
          expect {config.add_property("name", "philip")}.to raise_error
        end
      end

      context "when the given property already exists and its value is an empty string" do
        it "sets the property" do
          config.add_property("file")
          config.add_property("file", "file1.txt")
          expect(config.value_of("file")).to eql("file1.txt")
        end
      end

      context "when the given property already exists and is an array" do
        it "pushes the new value on to it" do
          config.add_property("name", "pj")
          config.add_property("name", "felipe")
          expect(config.value_of("name")).to match_array(["philip","pj","felipe"])
        end

        it "does not a value on to it if the value is not given" do
          config.add_property("name", "felipe")
          config.add_property("name")
          expect(config.value_of("name")).to match_array(["philip","felipe"])
        end

        it "throws an error if the value exists in the array already" do
          config.add_property("name", "felipe")
          expect {config.add_property("name", "felipe")}.to raise_error
        end
      end

      context "with string values that have colon-prefixed words" do
        it "does not allow them unless they reference properties" do
          expect {config.add_property("name", "hello i am :not_name")}.to raise_error
        end

        it "allows them when they reference properties" do
          expect {config.add_property("name", "hello i am :name")}.not_to raise_error
        end
      end
    end

    describe "#remove_property" do
      it "removes the stated property from the config" do
        config.remove_property("name")
        expect(config.value_of("name")).to be_false
      end

      it "raises an error if the property doesn't exist" do
        expect {config.remove_property("not.a.property")}.to raise_error
      end
    end

    describe "#pairs", :unnecessary => true do
      it "returns all of the key-value pairs" do
        expect(config.pairs).to eql(correct_config_pairs)
      end
    end

    describe "#properties", :unnecessary => true do
      it "returns all of the properties" do
        expect(config.properties).to match_array(correct_config_properties)
      end
    end

    describe "#to_h" do
      it "returns the config's pairs as a hash-tree" do
        config = WDI::Config::ConfigFile.new(config_json_contents_with_interpolation)
        expect(config.to_h).to eql(correct_config_hash)
      end
    end

    describe "#to_json" do
      it "returns the config's pairs as a JSON string representing the hash-tree" do
        config = WDI::Config::ConfigFile.new(config_json_contents_with_interpolation)
        expect(config.to_json).to eql(JSON.pretty_generate(correct_config_hash)) #
      end
    end

    describe "#to_s" do
      it "returns a string version of the contents (not the correct json, but key-val pairs)" do
        expect(config.to_s).to eql(config.pairs.to_s)
      end
    end

  end

end
