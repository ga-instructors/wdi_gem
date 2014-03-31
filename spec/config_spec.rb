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
        "repo": ":repos.classes.current",
        "pattern": "/$1/$2/:name"
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
        "repo": ":repos.classes.current",
        "pattern": "/$1/$2/:name"
      }
    }
    JSON_CONTENTS

    describe "#initialize" do
      it "raises an error if properties aren't formatted for the config to work" do
        expect {WDI::Config::ConfigFile.new('{"name1":"pj"}')}.to raise_error
        expect {WDI::Config::ConfigFile.new('{"name_":"pj"}')}.to raise_error
        expect {WDI::Config::ConfigFile.new('{"name.":"pj"}')}.to raise_error
        expect {WDI::Config::ConfigFile.new('{".name":"pj"}')}.to raise_error
      end
      
      it "allows bash commands in the values" do
        keys_values = {
          name: "`whoami`",
          base: "`echo $HOME`/dev/wdi",
          repos_classes_current: "`echo $HOME`/dev/wdi/class_name",
          go_repo: ":repos.classes.current",
          go_pattern: "/$1/$2/:name"
        }
        expect(WDI::Config::ConfigFile.new(config_json_contents_with_interpolation).pairs).to \
          eql(keys_values)
      end
    
      it "does not allow string values to have colon-prefixed words unless they reference properties" do
        expect {WDI::Config::ConfigFile.new('{"name":":not_name"}')}.to raise_error
      end
    end

    let!(:config) {WDI::Config::ConfigFile.new(config_json_contents)}

    describe "#value_at" do
      it "returns the value at the given key (as a symbol)" do
        expect(config.value_at(:name)).to eql("philip")
      end

      it "returns the value at the given key (as a string)" do
        expect(config.value_at("name")).to eql("philip")
      end

      it "works with dotted key strings appropriately" do
        expect(config.value_at("repos.classes.current")).to \
          eql("/Users/philip/dev/wdi/class_name")
      end

      it "works with underscored key symbols appropriately" do
        expect(config.value_at(:repos_classes_current)).to \
          eql("/Users/philip/dev/wdi/class_name")
      end

      it "raises an error when the key exists but is not a leaf node" do
        expect {config.value_at("repos.classes")}.to raise_error
        expect {config.value_at(:repos_classes)}.to raise_error
      end

      it "returns false when the key is not in the config file" do
        expect(config.value_at(:not_a_key)).to be_false
      end

      context "the value is a property reference, ie starts with a colon" do
        it "returns the referenced property value" do
          expect(config.value_at("go.repo")).to \
            eql("/Users/philip/dev/wdi/class_name")
        end

        it "works with either format for the reference" do
          config.set_key_value "go.repo", ":repos_classes_current"
          expect(config.value_at("go.repo")).to \
            eql("/Users/philip/dev/wdi/class_name")
        end

        it "interpolates if the reference is in the value" do
          expect(config.value_at("go.pattern")).to eql("/$1/$2/philip")
        end

        it "raises an error when the referenced property does not exist", :broken => true do
          allow(config).to receive(:disallow_bad_references_in) # not totally secure in this working...
          config.set_key_value "go.repo", ":not_a_value"

          expect {config.value_at("go.repo")}.to raise_error
        end
      end

      context "the value contains an allowed bash command" do
        let!(:config) {WDI::Config::ConfigFile.new(config_json_contents_with_interpolation)}
        
        it "returns the value with the command result interpolated" do
          expect(config.value_at("base")).to eql((`echo $HOME`).chomp + "/dev/wdi")
        end

        it "works even when it was referenced" do
          expect(config.value_at("go.repo")).to eql((`echo $HOME`).chomp + "/dev/wdi/class_name")
        end
      end
    end

    describe "#set_key_value" do
      it "updates the value at the given key" do
        config.set_key_value "name", "pj"
        expect(config.value_at("name")).to eql("pj")
      end

      it "works when key is given in symbol format" do
        config.set_key_value :repos_classes_current, "/"
        expect(config.value_at("repos.classes.current")).to eql("/")
      end

      it "raises an error if the key doesn't exist" do
        expect {config.set_key_value "nom", "pj"}.to raise_error
      end

      it "raises an error if the value isn't a string" do
        expect {config.set_key_value "name", :pj}.to raise_error
      end

      context "with string values that have colon-prefixed words" do
        it "does not allow them unless they reference properties" do
          expect {config.set_key_value "name", "hello i am :not_name"}.to raise_error
        end

        it "allows them when they reference properties" do
          expect {config.set_key_value "name", "hello i am :name"}.not_to raise_error
        end
      end
    end

    describe "#has_key?" do
      it "returns true if the key exists" do
        expect(config.has_key?("name")).to be_true
      end

      it "works when key is given in symbol format" do
        expect(config.has_key?(:repos_classes_current)).to be_true
      end

      it "returns false if the key doesn't exist" do
        expect(config.has_key?("nom")).to be_false
      end
    end

    describe "#keys_with_value" do
      it "returns the keys at the given value (as a symbol)" do
        expect(config.keys_with_value("philip")).to eql(["name"])
      end

      it "returns the keys with dots replaced by underscores" do
        expect(config.keys_with_value("/Users/philip/dev/wdi/class_name")).to \
          eql(["repos.classes.current"])
      end

      it "returns multiple keys if necessary" do
        config.add_key_value("repos.instructors.current", "/Users/philip/dev/wdi/class_name")
        expect(config.keys_with_value("/Users/philip/dev/wdi/class_name")).to \
          eql(["repos.classes.current","repos.instructors.current"])
      end

      it "returns false if the value is not present" do
        expect(config.keys_with_value("not_a_value")).to be_false
      end
    end

    describe "#keys_with_prefix" do
      it "returns the keys with the given prefix" do
        expect(config.keys_with_prefix("go")).to eql(["go.repo","go.pattern"])
      end

      it "returns the key itself if the prefix is a key" do
        expect(config.keys_with_prefix("go.repo")).to eql(["go.repo"])
      end

      it "returns false when the key is not present" do
        expect(config.keys_with_prefix("not_a_key")).to be_false
      end

      it "returns all keys when given no prefix" do
        keys = ["name","base","repos.classes.current","go.repo","go.pattern"]
        expect(config.keys_with_prefix).to match_array(keys)
      end
    end

    describe "#add_key_value" do
      it "adds a new key with the given value" do
        config.add_key_value("repos.instructors.current", "/Users/philip/dev/wdi/class_name")
        expect(config.value_at("repos.instructors.current")).to eql("/Users/philip/dev/wdi/class_name")
      end

      context "when the given key already exists and is not an array" do
        it "turns the property into an array and pushes the new value on to it" do
          config.add_key_value("name", "pj")
          expect(config.value_at("name")).to match_array(["philip","pj"])
        end
      end

      context "when the given key already exists and is an array" do
        it "pushes the new value on to it" do
          config.add_key_value("name", "pj")
          config.add_key_value("name", "felipe")
          expect(config.value_at("name")).to match_array(["philip","pj","felipe"])
        end
      end

      context "with string values that have colon-prefixed words" do
        it "does not allow them unless they reference properties" do
          expect {config.add_key_value("name", "hello i am :not_name")}.to raise_error
        end

        it "allows them when they reference properties" do
          expect {config.add_key_value("name", "hello i am :name")}.not_to raise_error
        end
      end
    end

    describe "#pairs", :unnecessary => true do
      it "returns all of the key-value pairs" do
        keys_values = {
          name: "philip",
          base: "/Users/philip/dev/wdi",
          repos_classes_current: "/Users/philip/dev/wdi/class_name",
          go_repo: ":repos.classes.current",
          go_pattern: "/$1/$2/:name"
        }
        expect(config.pairs).to eql(keys_values)
      end
    end

    describe "#keys", :unnecessary => true do
      it "returns all of the keys" do
        keys = ["name","base","repos.classes.current","go.repo","go.pattern"]
        expect(config.keys).to match_array(keys)
      end
    end

    describe "#to_h" do
      it "returns the config's pairs as a hash-tree" do
        config = WDI::Config::ConfigFile.new(config_json_contents_with_interpolation)
        hash_tree = {
          name: "`whoami`",
          base: "`echo $HOME`/dev/wdi",
          repos: {
            classes: {
              current: "`echo $HOME`/dev/wdi/class_name"
            }
          },
          go: {
            repo: ":repos.classes.current",
            pattern: "/$1/$2/:name"
          }
        }

        expect(config.to_h).to eql(hash_tree)
      end
    end

    describe "#to_json" do
      it "returns the config's pairs as a JSON string representing the hash-tree" do
        config = WDI::Config::ConfigFile.new(config_json_contents_with_interpolation)
        hash_tree = {
          name: "`whoami`",
          base: "`echo $HOME`/dev/wdi",
          repos: {
            classes: {
              current: "`echo $HOME`/dev/wdi/class_name"
            }
          },
          go: {
            repo: ":repos.classes.current",
            pattern: "/$1/$2/:name"
          }
        }
        
        expect(config.to_json).to eql(JSON.pretty_generate(hash_tree)) #
      end
    end

    describe "#to_s" do
      it "returns a string version of the contents (not the correct json, but key-val pairs)" do
        expect(config.to_s).to eql(config.pairs.to_s)
      end
    end

  end

end