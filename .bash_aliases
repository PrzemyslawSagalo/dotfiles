# Git
alias gs='git status'
alias gcb='git branch --show-current'
alias gpcb='git push origin $(gcb)'
alias gacw='git commit -am wip'
alias gdcb='git pull origin $(gcb)' # git download (pull) current branch
alias gl='git log'

# Tmux
alias tnwc='tmux new-window -c $(pwd)'

# Python
alias pal='source venv/bin/activate'
alias pce='python -m venv venv'
## Tests
alias ptcr='coverage report -m'

# Shell
alias se='set -a && source .env && set +a'
