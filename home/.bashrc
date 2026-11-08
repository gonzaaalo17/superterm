# .bashrc

# ble.sh (autosuggestions + syntax highlighting): loaded first, attached at the end
[[ $- == *i* ]] && [[ -f ~/.local/share/blesh/ble.sh ]] && source ~/.local/share/blesh/ble.sh --attach=none

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
    for rc in ~/.bashrc.d/*; do
        if [ -f "$rc" ]; then
            . "$rc"
        fi
    done
fi
unset rc

# Java (only if a JDK is installed)
if [ -d /usr/lib/jvm/java ]; then
    export JAVA_HOME=/usr/lib/jvm/java
    export PATH=$JAVA_HOME/bin:$PATH
fi

# Rust (only if rustup is installed)
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# Aliases
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# Custom functions
if [ -f ~/.bash_functs ]; then
    . ~/.bash_functs
fi

# ble.sh: attach at the very end, after everything else
[[ ! ${BLE_VERSION-} ]] || ble-attach
