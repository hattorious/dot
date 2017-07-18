# Run after os-specific settings and before *.local settings

# virtualenvwrapper stuff
export WORKON_HOME=$HOME/envs
if [[ -f /usr/local/bin/virtualenvwrapper.sh ]]; then
    . /usr/local/bin/virtualenvwrapper.sh;
fi
