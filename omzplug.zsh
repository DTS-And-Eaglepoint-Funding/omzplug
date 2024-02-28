# /bin/zsh
# http://github.com/mattmc3/omzplug
# Copyright mattmc3, 2020-2021
# MIT license, https://opensource.org/licenses/MIT
# omzplug - Plugins for Zsh made easy-omzplug



function _omzplug_help() {
  if [[ -n "$1" ]] && (( $+functions[omzplug_extended_help] )); then
    __omzplug_help_examples $@
    return $?
  else
    echo "omzplug - Plugins for Zsh made easy-omzplug"
    echo ""
    echo "usage:"
    echo "  omzplug <command> [<flags...>|<arguments...>]"
    echo ""
    echo "commands:"
    echo "  help      display this message"
    echo "  clone     download a plugin"
    echo "  initfile  display the plugin's init file"
    echo "  list      list all plugins"
    echo "  prompt    load a prompt plugin"
    echo "  pull      update a plugin, or all plugins"
    echo "  source    load a plugin"
    echo "  delete    delete a plugin"
  fi
}



function _omzplug_delete() {
  read "Are you sure? " -k 1 -r
  echo    # (optional) move to a new line
  if [[ ! $REPLY =~ ^[Yy]$ ]]
  then
      [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1 # handle exits from shell or function but don't exit interactive shell
      echo "$0"
  fi
}

function _omzplug_clone() {
  local gitserver; zstyle -s :omzplug:clone: default-gitserver gitserver || gitserver="github.com"
  local repo="$1"
  local plugin
  [[ -z "$2" ]] && plugin=${${1##*/}%.git} || plugin="$2"

  [[ ! -d "$OMZPLUG_PLUGIN_HOME/$plugin" ]] || return

  if [[ $repo != git://* &&
        $repo != https://* &&
        $repo != http://* &&
        $repo != ssh://* &&
        $repo != git@*:*/* ]]; then
    repo="https://${gitserver}/${repo%.git}.git"
  fi

  [[ -d "$OMZPLUG_PLUGIN_HOME" ]] || mkdir -p "$OMZPLUG_PLUGIN_HOME"
  command git -C "$OMZPLUG_PLUGIN_HOME" clone --depth 1 --recursive --shallow-submodules "$repo" "$plugin"
  [[ $? -eq 0 ]] || return 1
}

function _omzplug_initfile() {
  local plugin=${${1##*/}%.git}
  local plugin_path="$OMZPLUG_PLUGIN_HOME/$plugin"
  [[ -d $plugin_path ]] || return 2

  local search_files
  if [[ -z "$2" ]]; then
    search_files=(
      # look for specific files first
      $plugin_path/$plugin.plugin.zsh(.N)
      $plugin_path/$plugin.zsh(.N)
      $plugin_path/$plugin(.N)
      $plugin_path/$plugin.zsh-theme(.N)
      $plugin_path/init.zsh(.N)
      # then do more aggressive globbing
      $plugin_path/*.plugin.zsh(.N)
      $plugin_path/*.zsh(.N)
      $plugin_path/*.zsh-theme(.N)
      $plugin_path/*.sh(.N)
    )
  fi

  [[ ${#search_files[@]} -gt 0 ]] || return 1
  REPLY=${search_files[1]}
  echo $REPLY
}

function _omzplug_list() {
  local giturl name user repo shorthand flag_shorthand flag_detail
  if [[ "$1" == "-s" ]]; then
    flag_shorthand=true; shift
  fi
  if [[ "$1" == "-d" ]]; then
    flag_detail=true; shift
  fi
  for d in $OMZPLUG_PLUGIN_HOME/*(/N); do
    if [[ -d "$d"/.git ]]; then
      name="${d:t}"
      giturl=$(command git -C "$d" remote get-url origin)
      user=${${${giturl%/*}%.git}##*/}
      repo=${${giturl##*/}%.git}
      shorthand="$user/$repo"
    else
      name="${d:t}"
      giturl=
      user=
      repo=
      shorthand="$name"
    fi
    if [[ $flag_detail == true ]] && [[ -n "$giturl" ]]; then
      printf "%-30s | %s\n" ${name} ${giturl}
    elif [[ $flag_shorthand == true ]]; then
      echo "$shorthand"
    else
      echo "$name"
    fi
  done
}

function _omzplug_prompt() {
  local flag_add_only=false
  if [[ "$1" == "-a" ]]; then
    flag_add_only=true
    shift
  fi
  local repo="$1"
  local plugin=${${repo##*/}%.git}
  [[ -d "$OMZPLUG_PLUGIN_HOME/$plugin" ]] || _omzplug_clone $@
  fpath+="$OMZPLUG_PLUGIN_HOME/$plugin"
  if [[ $flag_add_only == false ]]; then
    autoload -U promptinit
    promptinit
    prompt "$plugin"
  fi
}

function _omzplug_pull() {
  emulate -L zsh; setopt local_options no_monitor
  local update_plugins
  [[ -n "$1" ]] && update_plugins=(${${1##*/}%.git}) || update_plugins=($(_omzplug_list))

  local p; for p in $update_plugins; do
    () {
      echo "${fg[cyan]}updating ${p:t}...${reset_color}"
      command git -C "$OMZPLUG_PLUGIN_HOME/$p" pull --quiet --recurse-submodules --depth 1 --rebase --autostash
      if [[ $? -eq 0 ]]; then
        echo "${fg[green]}${p:t} update successful.${reset_color}"
      else
        echo "${fg[red]}${p:t} update failed.${reset_color}"
      fi
    } &
  done
  wait
}

function _omzplug_source() {
  # check associative array cache for initfile to source
  local initfile_key="':omzplug:source:$1:$2:'"
  local initfile=$_omzplug_initfile_cache[$initfile_key]

  # if we didn't find an initfile in the lookup or it doesn't exist, then
  # clone the plugin if possible and save the initfile location to cache
  if [[ ! -f "$initfile" ]]; then
    local plugin=${${1##*/}%.git}
    local plugindir="$OMZPLUG_PLUGIN_HOME/$plugin"

    if [[ ! -d "$plugindir" ]]; then
      _omzplug_clone $1
      if [[ $? -ne 0 ]] || [[ ! -d "$plugindir" ]]; then
        echo >&2 "cannot find and unable to clone plugin"
        echo >&2 "'omzplug source $@' should find a plugin at $plugindir"
        return 1
      fi
    fi

    if [[ -z "$2" ]]; then
      initfile="$pluginpath/$plugin.plugin.zsh"
    else
      local subpath=${2%/*}
      local subplugin=${2##*/}
      initfile="$pluginpath/$subpath/$subplugin.plugin.zsh"
    fi

    # if we didn't find the expected initfile then search for one
    if [[ ! -f "$initfile" ]]; then
      _omzplug_initfile "$@" >/dev/null
      if [[ $? -ne 0 ]] || [[ ! -f "$REPLY" ]]; then
        echo >&2 "unable to find plugin initfile: $@" && return 1
      fi
      initfile=$REPLY
    fi

    # if we have invalid cache that gives the wrong result, fix it
    [[ -z "$_omzplug_initfile_cache[$initfile_key]" ]] || __omzplug_init_cache "reset"
    # add result to cache
    _omzplug_initfile_cache[$initfile_key]="$initfile"
    local stored_initfile_val="${initfile/#$OMZPLUG_PLUGIN_HOME\//\$OMZPLUG_PLUGIN_HOME/}"
    echo "_omzplug_initfile_cache[$initfile_key]=\"${stored_initfile_val}\"" >> "$OMZPLUG_CACHE_HOME/_omzplug_initfile_cache.zsh"
  fi

  fpath+="${initfile:h}"
  [[ -d ${initfile:h}/functions ]] && fpath+="${initfile:h}/functions"
  source "$initfile"
}


function __omzplug_init_cache() {
  if [[ ! -f "$OMZPLUG_CACHE_HOME/_omzplug_initfile_cache.zsh" ]] || [[ "$1" == "reset" ]]; then
    mkdir -p "$OMZPLUG_CACHE_HOME"
    echo "typeset -gA _omzplug_initfile_cache" > "$OMZPLUG_CACHE_HOME/_omzplug_initfile_cache.zsh"
  fi
  source "$OMZPLUG_CACHE_HOME/_omzplug_initfile_cache.zsh"
}

function omzplug() {
  local cmd="$1"
  local REPLY
  if (( $+functions[_omzplug_${cmd}] )); then
    shift
    _omzplug_${cmd} "$@"
    return $?
  elif [[ -z $cmd ]]; then
    _omzplug_help && return
  else
    echo >&2 "omzplug command not found: '${cmd}'" && return 1
  fi
}

() {
  # setup omzplug by setting some globals and autoloading anything in functions
  autoload colors && colors
  local basedir="${${(%):-%x}:a:h}"
  [[ -n "$OMZPLUG_CACHE_HOME" ]] || typeset -g OMZPLUG_CACHE_HOME="$basedir/.cache"
  [[ -n "$OMZPLUG_PLUGIN_HOME" ]] || typeset -g OMZPLUG_PLUGIN_HOME="${ZSH_CUSTOM}/plugins"
  typeset -gHa _omzplug_opts=( localoptions extendedglob globdots globstarshort nullglob rcquotes )
  __omzplug_init_cache
  # source ./functions/omzplug_extended_help.zsh
  if [[ -d $basedir/functions ]]; then
    typeset -gU FPATH fpath=( $basedir/functions $basedir $fpath )
    autoload -Uz $basedir/functions/*(.N)
    

  fi
}
