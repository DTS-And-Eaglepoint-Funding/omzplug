# Legacy OMZPLUG (Now Antidote)

**NOTE:** OMZPLUG is now Antidote, a feature-compatible implementation of the legacy
[Antibody](https://getantibody.github.io) plugin manager. This change introduces
breaking changes to legacy OMZPLUG. The original OMZPLUG will remain available on the
["omzplug" branch](https://github.com/mattmc3/antidote/tree/omzplug).

----------------------------------------------------------------------------------------

> OMZPLUG - Plugins for Zsh made easy-omzplug

A plugin manager for Zsh doesn't have to be _complicated_ to be **powerful**. OMZPLUG doesn't
try to be _clever_ when it can be **smart**. OMZPLUG is a full featured, fast, and easy to
understand plugin manager encapsulated in [a single, small, clean Zsh script][omzplug.zsh].

OMZPLUG does just enough to manage your Zsh plugins really well, and then gets out of your
way. And it's unit tested too to make sure it works as expected!

Plugins for Zsh made easy-omzplug.

## Usage

The help is pretty helpful. Run `omzplug help`:

```text
omzplug - Plugins for Zsh made easy-omzplug

usage:
  omzplug <command> [<flags...>|<arguments...>]

commands:
  help      display this message
  clone     download a plugin
  initfile  display the plugin's init file
  list      list all plugins
  prompt    load a prompt plugin
  pull      update a plugin, or all plugins
  source    load a plugin
  zcompile  compile your plugins' zsh files
```

You can also get extended help for commands by running `omzplug help <command>`:

```text
$ omzplug help source
usage:
  omzplug source <plugin> [<subpath>]

args:
  plugin   shorthand user/repo or full git URL
  subpath  subpath within plugin to use instead of root path

examples:
  omzplug source ohmyzsh
  omzplug source ohmyzsh/ohmyzsh lib/git
  omzplug source ohmyzsh/ohmyzsh plugins/extract
  omzplug source zsh-users/zsh-autosuggestions
  omzplug source https://github.com/zsh-users/zsh-history-substring-search
  omzplug source git@github.com:zsh-users/zsh-completions.git
```

## Installation

To install omzplug, simply clone the repo...

```shell
git clone https://github.com/mattmc3/omzplug.git ~/.config/zsh/plugins/omzplug
```

...and source omzplug from your `.zshrc`

```shell
source ~/.config/zsh/plugins/omzplug/omzplug.zsh
```

***- Or -***

You could add this snippet for total automation in your `.zshrc`

```shell
OMZPLUG_PLUGIN_HOME="${ZDOTDIR:-~/.config/zsh}/plugins"
[[ -d $OMZPLUG_PLUGIN_HOME/omzplug ]] ||
  git clone https://github.com/mattmc3/omzplug.git $OMZPLUG_PLUGIN_HOME/omzplug
source $OMZPLUG_PLUGIN_HOME/omzplug/omzplug.zsh
```

### Download your plugins

Downloading a plugin from a git repository referred to as cloning.
You can clone a plugin with partial or full git paths:

```shell
# clone with the user/repo shorthand (assumes github.com)
omzplug clone zsh-users/zsh-autosuggestions

# or, clone with a git URL
omzplug clone https://github.com/zsh-users/zsh-history-substring-search
omzplug clone git@github.com:zsh-users/zsh-completions.git
```

You can even rename a plugin if you prefer to call it something else:

```shell
# call it autosuggest instead
omzplug clone zsh-users/zsh-autosuggestions autosuggest
```

### Load your plugins

Loading a plugin means you source its primary plugin file.
You can source a plugin to use it in your interactive Zsh sessions.

```shell
omzplug source zsh-history-substring-search
```

If you haven't cloned a plugin already, you can still source it. It will be cloned
automatically, but in order to do that you will need to use its longer name or a full
git URL:

```shell
omzplug source zsh-users/zsh-history-substring-search
omzplug source https://github.com/zsh-users/zsh-autosuggestions
```

### Load a prompt/theme plugin

You can use prompt plugins too, which will set your theme. Prompt plugins are special
and are handled a little differently than sourcing regular plugins.

```shell
omzplug prompt sindresorhus/pure
```

Zsh has builtin functionality for switching and managing prompts. Running this Zsh
builtin command will give you a list of the prompt themes you have available:

```shell
prompt -l
```

If you would like to make more prompt themes available, you can use the `-a` flag. This
will not set the theme, but make it available to easily switch during your Zsh session.

For example, in your `.zshrc` add the following:

```shell
# .zshrc
# make a few other great prompts available
omzplug prompt -a miekg/lean
omzplug prompt -a romkatv/powerlevel10k

# and then set your default prompt to pure
omzplug prompt sindresorhus/pure
```

You can then switch to an available prompt in your interactive Zsh session:

```shell
$ # list available prompts
$ prompt -l
Currently available prompt themes:
adam1 adam2 bart bigfade clint default elite2 elite fade fire off ...

$ # now, switch to a different prompt
$ prompt pure
```

### Update your plugins

You can update a single plugin:

```shell
omzplug pull mattmc3/omzplug
```

Or, update all your plugins:

```shell
omzplug pull
```

### Oh My Zsh

If you use [Oh My Zsh][ohmyzsh], you are probably familiar with `$ZSH_CUSTOM`, which is
where you can add your own plugins to Oh My Zsh. By default, `$ZSH_CUSTOM` resides in
`~/.oh-my-zsh/custom`, but you can put it anywhere.

OMZPLUG is a stand alone plugin manager, but it also works really well to augment Oh My Zsh.
This is handy since Oh My Zsh doesn't have a way to manage external plugins itself.
To use OMZPLUG to manage your external Oh My Zsh plugins, simply set your `$OMZPLUG_PLUGIN_HOME`
variable to `$ZSH_CUSTOM/plugins`. For example, try adding this snippet to your
`.zshrc`:

```shell
# set omz paths somewhere in your script
ZSH=${ZSH:-${ZDOTDIR:-~}/.oh-my-zsh}
ZSH_CUSTOM=${ZSH_CUSTOM:-$ZSH/custom}

# set OMZPLUG's home to your omz custom path
OMZPLUG_PLUGIN_HOME=$ZSH_CUSTOM

# get OMZPLUG if you haven't already
[[ -d $OMZPLUG_PLUGIN_HOME/omzplug ]] ||
  git clone https://github.com/mattmc3/omzplug.git $OMZPLUG_PLUGIN_HOME/omzplug

# clone anything you need that omz didn't provide
omzplug clone zsh-users/zsh-autosuggestions
omzplug clone zsh-users/zsh-syntax-highlighting

# no need to source omzplug.zsh yourself if you put it in your plugins array
plugins=(... omzplug zsh-autosuggestions zsh-syntax-highlighting)

# source omz like normal
source $ZSH/oh-my-zsh.sh
```

*Alternatively*, if prefer to have OMZPLUG drive your configuration rather than Oh My Zsh,
but still want Oh My Zsh plugins and features, you can setup your config this way
instead:


```shell
# get OMZPLUG if you haven't already
[[ -d $OMZPLUG_PLUGIN_HOME/omzplug ]] ||
  git clone https://github.com/mattmc3/omzplug.git $OMZPLUG_PLUGIN_HOME/omzplug

# source regular plugins
omzplug source mafredri/zsh-async
omzplug source zsh-users/zsh-autosuggestions

# source OMZ libs and plugins
ZSH=$OMZPLUG_PLUGIN_HOME/ohmyzsh
omzplug source ohmyzsh/ohmyzsh lib/git
omzplug source ohmyzsh/ohmyzsh plugins/git
omzplug source ohmyzsh/ohmyzsh plugins/heroku
omzplug source ohmyzsh/ohmyzsh plugins/brew
omzplug source ohmyzsh/ohmyzsh plugins/fzf

# make the prompt pretty
omzplug prompt sindresorhus/pure

# always source syntax highlighting plugin last
omzplug source zsh-users/zsh-syntax-highlighting
```

## Customizing

### Plugin location

OMZPLUG stores your plugins in your `$ZDOTDIR/plugins` directory.
If you don's use `$ZDOTDIR`, then `~/.config/zsh/plugins` is used.

But, if you prefer to store your plugins someplace else, you can always change the
default plugin location. Do this by setting the `OMZPLUG_PLUGIN_HOME` variable in your
`.zshrc` before sourcing OMZPLUG:

```shell
# use a custom directory for omzplug plugins
OMZPLUG_PLUGIN_HOME=~/.omzplugplugins
```

Also note that it is recommended that you store OMZPLUG in the same place as your other
plugins so that `omzplug pull` will update OMZPLUG.

If you store your Zsh configuration in a [dotfiles][dotfiles] reporitory, it is
recommended to add your preferred `$OMZPLUG_PLUGIN_HOME` to your `.gitignore` file.

### Git URL

Don't want to use GitHub.com for your plugins? Feel free to change the default git URL
with this `zstyle` in your `.zshrc`:

```shell
# bitbucket.org or gitlab.com or really any git service
zstyle :omzplug:clone: gitserver bitbucket.org
```

## .zshrc

An example `.zshrc` might look something like this:

```shell
### ${ZDOTDIR:-~}/.zshrc

# setup your environment
...

# then setup omzplug
OMZPLUG_PLUGIN_HOME="${ZDOTDIR:-~/.config/zsh}/plugins"
[[ -d $OMZPLUG_PLUGIN_HOME/omzplug ]] ||
  git clone https://github.com/mattmc3/omzplug.git $OMZPLUG_PLUGIN_HOME/omzplug
source $OMZPLUG_PLUGIN_HOME/omzplug/omzplug.zsh

# source plugins from github
omzplug source zsh-users/zsh-autosuggestions
omzplug source zsh-users/zsh-history-substring-search
omzplug source zsh-users/zsh-completions
omzplug source zsh-users/zsh-syntax-highlighting

# source ohmyzsh plugins
omzplug source ohmyzsh/ohmyzsh plugins/colored-man-pages

# set your prompt
omzplug prompt sindresorhus/pure

# -or- use oh-my-zsh themes instead of a prompt plugin
omzplug source ohmyzsh lib/git
omzplug source ohmyzsh lib/theme-and-appearance
omzplug source ohmyzsh themes/robbyrussell
```

[ohmyzsh]: https://ohmyz.sh
[dotfiles]: https://dotfiles.github.io
[omzplug.zsh]: https://github.com/mattmc3/omzplug/blob/main/omzplug.zsh
