function __omzplug_help_examples() {
  if [[ $1 == "--no-header" ]]; then
    shift
  else
    echo "examples:"
  fi
  echo "  omzplug $1 zsh-users/zsh-autosuggestions"
  echo "  omzplug $1 https://github.com/zsh-users/zsh-history-substring-search"
  echo "  omzplug $1 git@github.com:zsh-users/zsh-completions.git"

case "$1" in
  clone)
    echo "usage:"
    echo "  omzplug clone <plugin> [<renamed-plugin>]"
    echo ""
    echo "args:"
    echo "  plugin  shorthand user/repo or full git URL"
    echo ""
    __omzplug_help_examples "clone"
    echo "  omzplug clone zsh-users/zsh-autosuggestions autosuggest"
    ;;
  initfile)
    echo "usage:"
    echo "  omzplug initfile <plugin> [<subpath>]"
    echo ""
    echo "description:"
    echo "  show the file that will be sourced to initialize a plugin"
    echo ""
    echo "args:"
    echo "  plugin   shorthand user/repo or full git URL"
    echo "  subpath  subpath within plugin to use instead of root path"
    echo ""
    echo "examples:"
    echo "  omzplug source ohmyzsh"
    echo "  omzplug source ohmyzsh/ohmyzsh lib/git"
    echo "  omzplug source ohmyzsh/ohmyzsh plugins/extract"
    __omzplug_help_examples --no-header "source"
    ;;
  list)
    echo "usage:"
    echo "  omzplug list [-s|-d]"
    echo ""
    echo "flags:"
    echo "  -s   use the shorthand git name for plugins (user/repo)"
    echo "  -d   provide more details in the plugin list"
    ;;
  prompt)
    echo "usage:"
    echo "  omzplug prompt [-a] <prompt-plugin>"
    echo ""
    echo "flags:"
    echo "  -a   Adds a prompt, but does not set it as the theme"
    echo ""
    echo "args:"
    echo "  prompt-plugin   shorthand user/repo or full git URL"
    echo ""
    echo "examples:"
    echo "  omzplug prompt -a https://github.com/agnoster/agnoster-zsh-theme"
    echo "  omzplug prompt -a git@github.com:miekg/lean.git"
    echo "  omzplug prompt -a romkatv/powerlevel10k"
    echo "  omzplug prompt sindresorhus/pure"
    ;;
  pull)
    echo "usage:"
    echo "  omzplug pull [<plugin>]"
    echo ""
    echo "args:"
    echo "  plugin  shorthand user/repo or full git URL"
    echo ""
    __omzplug_help_examples "pull"
    ;;
  delete)
    echo "usage:"
    echo "  omzplug delete [<plugin>]"
    echo ""
    echo "args:"
    echo "  plugin"
    echo ""
    __omzplug_help_examples "delete"
    ;;
  source)
    echo "usage:"
    echo "  omzplug source <plugin> [<subpath>]"
    echo ""
    echo "args:"
    echo "  plugin   shorthand user/repo or full git URL"
    echo "  subpath  subpath within plugin to use instead of root path"
    echo ""
    echo "examples:"
    echo "  omzplug source ohmyzsh"
    echo "  omzplug source ohmyzsh/ohmyzsh lib/git"
    echo "  omzplug source ohmyzsh/ohmyzsh plugins/extract"
    __omzplug_help_examples --no-header "source"
    ;;
  *)
    echo "No extended help available for command: $@"
    return 1
    ;;
esac
}