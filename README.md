# The WDI Gem

Use this gem to create WDI configurations, make changes to them, and access them in a standard way. WDI configurations exist in the directory `~/.wdi`, and should be used by the breadth of WDI instructor and student (classroom) tools in order to define common constants for development/environmental settings. The base configuration file is `~/.wdi/config.json`.

The purpose of having a standardized configuration wrapper is to ease the creation of classroom tools and practices relating directly to the WDI development environment.

**To that end, there are three major parts to this gem:**

1. a module you can include in your own tools,
2. a command line tool you can use in the terminal or in scripts (such as the Installfest script),
3. a suggested set of standards for creating tools that will work in any WDI classroom, and with other WDI classroom tools. This effort is just beginning, and we are looking for input on how these standards should work.

Send me (PJ) any suggestions or changes either in HipChat or as a pull request!

This gem is heavily indebted to designs used in [Confstruct](https://github.com/mbklein/confstruct) and [Hashie](https://github.com/intridea/hashie).

## Installation

```bash
gem install wdi
```

It's as easy as that! From this point on you can begin using the command line tool `wdi`.

To include the module in your tool, add it to your Gemfile or .gemspec.

**Warning:** the current `.bash_profile` in common use by WDI NYC has aliased `wdi` to the command `cd ~/dev/wdi`. This will override the `wdi` executable loaded in the path by the gem. The alias needs to be removed from the profile and the shell reloaded for the tool to run.

## Use as a Module in Your Tool or Project

#### Access and set properties in the WDI config file

```ruby
require "wdi/config" # require the WDI::Config module

module WDI
  module Tools
    class SomeTool
      def initialize
        @student_name = Config.name
        @class_repo   = Config.cohorts.current.repo
        Config.some_tool.last_used = Time.now
      end
    end
  end
end
```



## Use as a Command Line Tool

#### Create a WDI directory and config file

```bash
wdi init
```

As long as there is no `~/.wdi` directory, this command creates one. By default it adds a single file, `config.json`, to the directory: either the template file that comes with this gem (in `data/default-config.json`), or (if specified) it is copied from another template at the given URI.

Examples:

```bash
wdi init https://raw.githubusercontent.com/h4w5/example_config/master/config.json
#=> pulls from GitHub
wdi init ~/dev/wdi/example_configs/config1.json
#=> pulls from a local file
```

If there is already a directory, you can forcefully overwrite it by using the "-f" switch. This removes **everything** except for the single `config.json` file. See the **Standards** section for why.

#### Edit a WDI config file

All WDI config files have a similar structure, described in **Standards** below. They all rest in the base of the `~/.wdi` directory, and are all stored as `.json` files. If the config file's name is `go.json` (for an example, if there were a tool named Go that needed it's own configuration...), you could list its properties with:

```bash
wdi go properties
```

The standard, default config file (`~/.wdi/config.json`) is therefore accessed with:

```bash
wdi config properties
```

In addition to listing the properties in the config file, you can set or get properties' values, or add and remove them.

Get a property:

```bash
# wdi config get <property>
wdi config get name
#=> PJ

wdi config get cohorts
#=> ["current", "WDI NYC Jan14", "WDI NYC ArraySep13"]

wdi config get cohorts_current
#=> "WDI NYC Jan14"
```

Set a property:

```bash
# wdi config set <property> <value>
wdi config set name Philip
wdi config get name
#=> Philip
```

Add a property:

```bash
# wdi config add <property> <value>
wdi config add middle-name Jordan
wdi config get middle-name
#=> Jordan

wdi config add middle-name John
wdi config get middle-name
#=> ['John', 'Jordan']
```

Remove a property:

```bash
# wdi config remove <property> (<value>) (--force)
wdi config remove name
#=> Are you sure you want to remove property 'name'? [Yn] y
#=> Config property 'name' removed.

wdi config get name
#=> There is no config property 'name'.

wdi config remove middle-name John --force
#=> Config property 'middle-name: John' removed.
wdi config get middle-name
#=> Jordan
```

#### Editing the WDI directory

As the `~/.wdi` directory is meant as a general storage place for tools, you can add or remove files or repos to it via the WDI gem.

Add files:

```bash
# wdi files add <file> (<file>, ...)
wdi files add tool.json tool.rb

ls ~/.wdi
#=>config.json  tool.json  tool.rb
```

Also: the base config file keeps track of the files stored in `~/.wdi` under the *files* property.

```bash
wdi config files
#=> ["config.json", "tool.json", "tool.rb"]
```

Remove files:

```bash
# wdi files remove <file> (--force)
wdi files remove tool.rb
#=> Are you sure you want to remove file 'tool.rb'? [Yn] y
#=> File 'name' removed.

ls ~/.wdi
#=>config.json  tool.json
```

Also: the base config file keeps track of the files stored in `~/.wdi` under the *files* property.

```bash
wdi config files
#=> ["config.json", "tool.json"]
```

Add repos:

```bash
# wdi repos add <repo name> <repo git link>
wdi repos add exercises git@github.com:ga-instructors/wdi_exercises.git

wdi config repos
#=> ["exercises"]
wdi config repos_exercises
#=> "wdi_exercises/"
```

## Standardization

### WDI Directory Structure

...TBD...

### Config File Structure

...TBD...

The config file is a basic JSON "hash" -- key-value pairs, where the value can be a string, and array (list), or another "hash." In this sense, when the value is a string or an array, ie it is a leaf node of the "hash tree," it is a ***property.*** The property is represented as either the key, or the series of key_childkey_childkey until you reach the leaf node, with an underscore in between.

- **name**
- **base**
- **cohorts**
  - **current**
  - **_cohort-name_**
- **files**
- **repos**
- **commands**

### Naming

```ruby
WDI::Config    # the base WDI config file
WDI::Directory # interactions with the WDI directory
WDI::Tools     # a general namespace for tools
```

...TBD...

## Development

#### Testing

Use **Aruba** (Cucumber) for CLI acceptance testing, and **Rspec** for unit testing the non-CLI modules and classes. Aruba is run with the `rake test` command, and tests are in the `/features` directory, while Rspec with the `bundle exec rspec` command (test in `/specs`, as per usual).

> Note: I'm tempted to add 'active_support/core_ext/string/inflections' as a requirement... I imagine it's insanely heavy, but should be on systems already if Rails is there... But we should try to be slim if this tool is going to be required in every WDI command line tool, right?
