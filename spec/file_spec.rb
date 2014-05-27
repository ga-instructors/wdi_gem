require "spec_helper"

describe WDI::Folder do
  describe WDI::Folder::Files do

    let(:config) {WDI::Config::config}

    describe "::add", :fakefs => true do
      # it "adds the file to the WDI directory, under files" do
      #   FakeFS.activate!
        
      #   WDI::Folder::Files.add "repos.curriculum", f
      #   expect(true).to be_false
      #   FakeFS.deactivate!
      # end

      # it "adds the property to the config" do
      # end

      # it "adds a reference to the property to the list of files in config" do
      # end
    end

    # describe "::addRecursive" do

    # end

    describe "::remove" do
      # it "removes the reference to the property to the list of files in config" do
      # end
    end
  end
end