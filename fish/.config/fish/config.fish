# Commands to run in interactive sessions can go here
if status is-interactive
    # No greeting
    set fish_greeting

    # Use starship
    function starship_transient_prompt_func
        starship module character
    end
    if test "$TERM" != "linux"
        starship init fish | source
        enable_transience
    end
    
    # Colors
    if test -f ~/.local/state/quickshell/user/generated/terminal/sequences.txt
        cat ~/.local/state/quickshell/user/generated/terminal/sequences.txt
    end

    # Aliases
    # kitty doesn't clear properly so we need to do this weird printing
    alias clear "printf '\033[2J\033[3J\033[1;1H'"
    alias c "printf '\033[2J\033[3J\033[1;1H'"
    alias celar "printf '\033[2J\033[3J\033[1;1H'"
    alias claer "printf '\033[2J\033[3J\033[1;1H'"
    alias pamcan pacman
    alias q 'qs -c ii'

    # Navigation
    alias .. 'cd ..'
    alias ... 'cd ../..'
    alias .... 'cd ../../..'
    alias -- - 'cd -'

    # Kitty SSH
    if test "$TERM" = "xterm-kitty"
        alias ssh 'kitten ssh'
    end

    # Neovim
    alias v nvim
    alias vi nvim
    alias vim nvim

    # Quick edit
    alias zshrc "vim ~/.config/fish/config.fish"
    alias kittyrc "vim ~/.config/kitty/kitty.conf"
    alias nvimrc "vim ~/.config/nvim/init.lua"

    # Git
    alias g git
    alias ga 'git add'
    alias gc 'git commit'
    alias gca 'git commit --amend --no-edit'
    alias gp 'git push'
    alias gpf 'git push --force-with-lease'
    alias gl 'git log --oneline --graph'
    alias gs 'git status'
    alias gd 'git diff'
    alias gco 'git checkout'
    alias gcb 'git checkout -b'
    alias gpl 'git pull --rebase'
    alias gst 'git stash'
    alias grb 'git rebase'
    alias grbc 'git rebase --continue'
    alias grba 'git rebase --abort'
    alias gcl 'git clone'
    alias gdi 'git diff --cached'
    alias gb 'git branch'
    alias gba 'git branch -a'
    alias gmt 'git mergetool'

    # System
    alias cat 'bat --paging=never'
    alias grep 'rg'
    alias find 'fd'
    alias df 'df -h'
    alias du 'du -h'
    alias mkdir 'mkdir -p'
    alias tree 'eza -T --icons'
    alias ports 'ss -tulanp'
    alias myip 'curl -s ifconfig.me'
    alias weather 'curl -s wttr.in'
    alias python python3
    alias pip pip3
    alias top 'btm' 2>/dev/null; or alias top 'htop'

    # Reload
    alias reload 'exec fish'
    alias refresh 'source ~/.config/fish/config.fish'

    # Color regeneration
    alias matugen-regen '~/.config/matugen/regenerate.sh'
end


# Added by Antigravity CLI installer
set -gx PATH "/home/anasa/.local/bin" $PATH

# opencode
fish_add_path /home/anasa/.opencode/bin
