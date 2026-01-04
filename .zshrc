# /usr/share/zsh/plugins/zsh-syntax-highlighting/highlighters/brackets/brackets-highlighter.zsh
# /usr/share/zsh/plugins/zsh-syntax-highlighting/highlighters/cursor/cursor-highlighter.zsh
# /usr/share/zsh/plugins/zsh-syntax-highlighting/highlighters/line/line-highlighter.zsh
# /usr/share/zsh/plugins/zsh-syntax-highlighting/highlighters/main/main-highlighter.zsh
# /usr/share/zsh/plugins/zsh-syntax-highlighting/highlighters/pattern/pattern-highlighter.zsh
# /usr/share/zsh/plugins/zsh-syntax-highlighting/highlighters/regexp/regexp-highlighter.zsh
# /usr/share/zsh/plugins/zsh-syntax-highlighting/highlighters/root/root-highlighter.zsh
# /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000

setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS
setopt share_history
setopt correct

# Command completion
autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}'

## Manual prompt ZSH start
# Load colors once at startup
autoload -Uz colors && colors
# Git prompt with caching and remote tracking
typeset -g last_git_check=0 git_cache=""
async_git_info() {
    # Check cache (5 second TTL)
    if (( $(date +%s) < last_git_check + 5 )) && [[ -n "$git_cache" ]]; then
        echo "$git_cache"
        return
    fi
    # Get Git info
    ref=$(git branch --show-current 2>/dev/null) || return
    [ -z "$ref" ] && return
    # Dirty state
    dirty=""
    [ -n "$(git status -s 2>/dev/null)" ] && dirty=" ±"
    # Remote tracking
    local ahead=0 behind=0
    git rev-list --count --left-right @{upstream}...HEAD 2>/dev/null | IFS=$'\t' read behind ahead
    remote_status=""
    (( behind > 0 )) && remote_status+=" ↓$behind"
    (( ahead > 0 )) && remote_status+=" ↑$ahead"
    # Build cache
    git_cache=" ${ref}${dirty}${remote_status}" # alternative icon 
    last_git_check=$(date +%s)
    echo "$git_cache"
}
# Time formatting with hours support
format_time() {
    local t=$1
    (( t >= 3600 )) && printf "%dh%dm%ds" $((t/3600)) $((t%3600/60)) $((t%60)) && return
    (( t >= 60 )) && printf "%dm%ds" $((t/60)) $((t%60)) && return
    printf "%ds" $t
}
# Timing variables
typeset -g cmd_start=0
# Track command start time
preexec() { cmd_start=$SECONDS }
# Build prompt (single-line PROMPT declaration)
precmd() {
    local exit_status=$? git_prompt=$(async_git_info) cmd_time="" duration=0 venv_prompt=""
    (( cmd_start > 0 )) && (( duration = SECONDS - cmd_start )) && (( duration >= 1 )) && cmd_time="%B%F{cyan} $(format_time $duration)%f%b"
    [[ -n "$VIRTUAL_ENV" ]] && venv_prompt="%F{red}(%F{yellow}${VIRTUAL_ENV##*/}%F{red})%f "
    PROMPT="%F{green}╭─%f %B%F{magenta}[%~]%f ${venv_prompt}%F{green}${git_prompt}%f %(?.%F{green}🗸.%F{red}✘ %F{red}%?)%f${cmd_time}"$'\n'"%F{green}╰─%f %F{yellow}%f%b "
    cmd_start=0
}
## Manual prompt ZSH end

## Changing the syntax colour to blue from the default green i guess!
ZSH_HIGHLIGHT_STYLES[suffix-alias]=fg=cyan,bold
ZSH_HIGHLIGHT_STYLES[precommand]=fg=cyan,bold
ZSH_HIGHLIGHT_STYLES[arg0]=fg=cyan,bold

# Classic colored man pages
export LESS_TERMCAP_mb=$(tput bold; tput setaf 1)      # Red - blinking
export LESS_TERMCAP_md=$(tput bold; tput setaf 2)      # Green - bold headers
export LESS_TERMCAP_se=$(tput sgr0)                    # End standout
export LESS_TERMCAP_us=$(tput smul; tput setaf 4)      # Blue - underline
export LESS_TERMCAP_ue=$(tput sgr0)                    # End underline
export LESS_TERMCAP_me=$(tput sgr0)                    # End all modes
export LESS_TERMCAP_so=$(tput setab 3; tput setaf 0)   # Highlighting foralternative-->(6,0)
# Use MANROFFOPT for compatibility
export MANROFFOPT="-c"
