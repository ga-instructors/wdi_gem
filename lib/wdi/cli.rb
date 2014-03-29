require "thor"

module WDI
  class CLI < Thor
    desc "init", "initialize a new WDI directory (~/.wdi)"
    def init
      say "initializing!"
    end
  end
end