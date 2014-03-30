# The WDI Tool

Use this gem to set up the WDI configuration file(s) and make changes to them. These exist in the folder ~/.wdi, and are used by the breadth of WDI command line tools in order to define common constants or development/environmental settings specific to the WDI command line tools.

## Installation

```bash
gem install wdi
```

It's as easy as that!

**Warning:** the current `.bash_profile` in common use by WDI NYC has aliased `wdi` from the command `cd ~/dev/wdi`. This will override the `wdi` executable loaded in the path by the gem. The alias needs to be removed from the profile and the shell reloaded for the tool to run.

## Usage

#### Creating a WDI folder and config file

```bash
wdi init
```

As long as there is no `~/.wdi` folder, this command creates one. By default it uses the template file at `data/default-config.json`. If there is already a folder, you can forcefully overwrite it by using the "-f" switch. You can also specify a "load" file or URL template to copy the `config.json` file from.

#### Editing the WDI folder

```bash
# wdi add <file>
```

...

#### Editing a WDI config file

```bash
wdi config set <key(.key...)> <value>
wdi config get <key(.key...)>

# wdi config add <key(.key...)> <value>
# wdi config remove <key(.key...)> (--force)

wdi config keys (<key>)

# wdi get-base
# wdi get-repo class.current
```

...

#### Navigating WDI repos

```bash
# wdi go [go=repos.classes.current] <week_num> <day_num>
```

...
