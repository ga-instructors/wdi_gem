# The WDI Tool

Use this gem to set up the WDI configuration file(s) and make changes to them. These exist in the directory ~/.wdi, and are used by the breadth of WDI command line tools in order to define common constants or development/environmental settings specific to the WDI command line tools.

## Installation

```bash
gem install wdi
```

It's as easy as that!

**Warning:** the current `.bash_profile` in common use by WDI NYC has aliased `wdi` to the command `cd ~/dev/wdi`. This will override the `wdi` executable loaded in the path by the gem. The alias needs to be removed from the profile and the shell reloaded for the tool to run.

## Usage

#### Creating a WDI directory and config file

```bash
wdi init
```

As long as there is no `~/.wdi` directory, this command creates one. By default it uses the template file at `data/default-config.json`. If there is already a directory, you can forcefully overwrite it by using the "-f" switch. You can also specify a "load" file or URL template to copy the `config.json` file from.

#### Editing the WDI directory

```bash
# wdi add-files <files>
```

... TBD (adds a file or files to the directory, and requisite keys *files.filename* to the config)...

#### Editing a WDI config file

```bash
wdi config set <key(.key...)> <value>
wdi config get <key(.key...)>

# wdi config add <key(.key...)> <value>
# wdi config remove <key(.key...)> (--force)

wdi config keys (<key>)

# wdi get-<key>
# wdi get-<key-parent> <rest.of.key>
# wdi add-key <key> <value>
# wdi set-<key> <value>
```

... TBD ...

#### Navigating WDI repos

```bash
# wdi go [:go.repo] [:go.pattern] <args>
```

... TBD ...

## Development

#### Testing

Use **Aruba** (Cucumber) for CLI acceptance testing, and **Rspec** for unit testing the non-CLI modules and classes. Aruba is run with the `rake test` command, and tests are in the `/features` directory, while Rspec with the `bundle exec rspec` command (test in `/specs`, as per usual).

> Note: I'm tempted to add 'active_support/core_ext/string/inflections' as a requirement... I imagine it's insanely heavy, but should be on systems already if Rails is there... But we should try to be slim if this tool is going to be required in every WDI command line tool, right?
