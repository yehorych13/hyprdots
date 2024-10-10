export ZSH="$HOME/.oh-my-zsh"

# ZSH_THEME="xiong-chiamiov-plus"
ZSH_THEME="powerlevel10k/powerlevel10k"

ENABLE_CORRECTION="true"

plugins=(git sudo zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

fastfetch -c $HOME/.config/fastfetch/config-compact.jsonc

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

unsetopt correct

# bun completions
[ -s "/home/yehorych/.bun/_bun" ] && source "/home/yehorych/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
