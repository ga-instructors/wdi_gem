# The WDI Tool

Use this gem to set up the WDI configuration file(s) and make changes to them. These exist in the folder ~/.wdi, and are used by the breadth of WDI command line tools in order to define common constants or development/environmental settings specific to the WDI command line tools.

## Usage

```bash
wdi init (--load URI)
#=> if there is no .wdi folder, it creates one
#=>   by default it uses the example in data/default-config.json, or if
#=>   --load is defined (as a URI), then it attempts to use that
#=> if there is a .wdi folder, this fails and suggests using `wdi config`
```

```bash
wdi config set <key(.key...)> <value>
wdi config get <key(.key...)>

wdi config add <key(.key...)> <value>
wdi config remove <key(.key...)> (--force)

wdi config keys (<key>)

# wdi get-base
# wdi get-repo class.current
```