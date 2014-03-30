# The WDI Tool

Use this gem to set up the WDI configuration file(s) and make changes to them. These exist in the folder ~/.wdi, and are used by the breadth of WDI command line tools in order to define common constants or development/environmental settings specific to the WDI command line tools.

## Installation

```bash
gem install wdi
```

It's as easy as that! **Warning:** the current common .bash_profile in use in NYC has aliased `wdi` to a `cd ~/dev/wdi` command

## Usage

#### Creating a WDI folder and config file

```bash
wdi init (--load URI)
#=> if there is no .wdi folder, it creates one
#=>   by default it uses the example in data/default-config.json, or if
#=>   --load is defined (as a URI), then it attempts to use that
#=> if there is a .wdi folder, this fails and suggests using `wdi config`
```

### Editing the WDI folder

```bash
wdi add <file>
```

#### Editing a WDI config file

```bash
wdi config set <key(.key...)> <value>
wdi config get <key(.key...)>

wdi config add <key(.key...)> <value>
wdi config remove <key(.key...)> (--force)

wdi config keys (<key>)

# wdi get-base
# wdi get-repo class.current
```

#### Navigating WDI repos

```bash
wdi go [go=repos.classes.current] <week_num> <day_num>
```
