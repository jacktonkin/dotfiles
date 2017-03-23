if [ "$TERM" != "dumb" ]; then
    export LS_OPTIONS='--color=auto --human-readable'
    eval `gdircolors -b`
fi

# Useful aliases
alias ls='gls $LS_OPTIONS'
alias mvim='mvim --remote-tab-silent'
alias vi=mvim
alias vim=mvim
alias vimdiff=mvimdiff
alias mview='command mvim -R --servername VIEW --remote-tab-silent'
alias view=mview
alias quicklook='qlmanage -p'

# Set editor for commmit messages
export EDITOR='command mvim -f'

# Bash history searching with arrow keys
bind '"\e[A":history-search-backward'
bind '"\e[B":history-search-forward'

# Set up path.  Homebrew puts stuff in /usr/local/sbin.
# For other package managers:
# Brewed python includes pip, which puts things in /usr/local/bin
# Brewed node includes npm which puts things in /usr/local/bin with the -g flag
# For gems use brew-gem.
# For composer set the bin-dir in ~/.composer/composer.json to ~/bin
export PATH=~/bin:/usr/local/sbin:$PATH

# Bash completions provided by homebrew
if [ -f $(brew --prefix)/etc/bash_completion ]; then
  . $(brew --prefix)/etc/bash_completion
fi

# Include Drush prompt customizations.
. /Users/jack/.drush/drush.prompt.sh
# Just show path in prompt, followed by git, drush info and bold $.
export PROMPT_COMMAND='__git_ps1 "\w" "$(__drush_ps1 "[%s]") \[\e[1m\]\\\$\[\e[0m\] "'

# Quick way to rebuild the Launch Services database and get rid
# of duplicates in the Open With submenu.
# http://www.leancrew.com/all-this/2013/02/getting-rid-of-open-with-duplicates/
alias fixopenwith='/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user'

# Next Action script
[[ -s "/Users/jack/Scripts/na.sh" ]] && source "/Users/jack/Scripts/na.sh"

# Copy text file contents to clipboard
function clip() {
    type=`file "$1"|grep -c text`
    if [ $type -gt 0 ]; then
        cat "$@"|pbcopy
        echo "Contents of $1 are in the clipboard."
    else
        echo "File \"$1\" is not plain text."
    fi
}

# Remote Mount (sshfs)
# creates mount folder and mounts the remote filesystem
function rmount() {
    local host folder mname
    host="${1%%:*}:"
    [[ ${1%:} == ${host%%:*} ]] && folder='' || folder=${1##*:}
    if [[ $2 ]]; then
        mname=$2
    else
        mname=${folder##*/}
        [[ "$mname" == "" ]] && mname=${host%%:*}
    fi
    if [[ $(grep -i "host ${host%%:*}" ~/.ssh/config) != '' ]]; then
        mkdir -p ~/mounts/$mname > /dev/null
        sshfs $host$folder ~/mounts/$mname -oauto_cache,reconnect,defer_permissions,negative_vncache,volname=$mname,noappledouble && echo "mounted ~/mounts/$mname"
    else
        echo "No entry found for ${host%%:*}"
        return 1
    fi
}

# Remote Umount, unmounts and deletes local folder (experimental, watch you step)
function rumount() {
    if [[ $1 == "-a" ]]; then
        ls -1 ~/mounts/|while read dir
        do
            [[ $(mount|grep "mounts/$dir") ]] && umount ~/mounts/$dir
            [[ $(ls ~/mounts/$dir) ]] || rm -rf ~/mounts/$dir
        done
    else
        [[ $(mount|grep "mounts/$1") ]] && umount ~/mounts/$1
        [[ $(ls ~/mounts/$1) ]] || rm -rf ~/mounts/$1
    fi
}

# cd to the path of the front Finder window
cdf() {
    target=`osascript -e 'tell application "Finder" to if (count of Finder windows) > 0 then get POSIX path of (target of front Finder window as text)'`
    if [ "$target" != "" ]; then
        cd "$target"; pwd
    else
        echo 'No Finder window found' >&2
    fi
}

# Open current path in Finder
alias f='open -a Finder ./'

# Quickly get image dimensions from the command line
function imgsize() {
    local width height
    if [[ -f $1 ]]; then
        height=$(sips -g pixelHeight "$1"|tail -n 1|awk '{print $2}')
        width=$(sips -g pixelWidth "$1"|tail -n 1|awk '{print $2}')
        echo "${width} x ${height}"
    else
        echo "File not found"
    fi
}

# encode a given image file as base64 and output css background property to clipboard
function 64enc() {
    openssl base64 -in $1 | awk -v ext="${1#*.}" '{ str1=str1 $0 }END{ print "background:url(data:image/"ext";base64,"str1");" }'|pbcopy
    echo "$1 encoded to clipboard"
}

function 64font() {
    openssl base64 -in $1 | awk -v ext="${1#*.}" '{ str1=str1 $0 }END{ print "src:url(\"data:font/"ext";base64,"str1"\")  format(\"woff\");" }'|pbcopy
    echo "$1 encoded as font and copied to clipboard"
}

# Speedtest on the command line http://osxdaily.com/2013/07/31/speed-test-command-line/
alias speedtest='wget -O /dev/null http://speedtest.wdc01.softlayer.com/downloads/test10.zip'

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

function httpless {
    # `httpless example.org'
    http --pretty=all --print=hb "$@" | less -R;
}

fp () { #find and list processes matching a case-insensitive partial-match string
    ps Ao pid,comm|awk '{match($0,/[^\/]+$/); print substr($0,RSTART,RLENGTH)": "$1}'|grep -i $1|grep -v grep
}

# build a menu of processes matching (case-insensitive, partial) first parameter
# now automatically tries to use the `quit` script if process is a Mac app <http://jon.stovell.info/personal/Software.html>
fk () {
    local cmd OPT
    IFS=$'\n'
    PS3='Kill which process? (q to cancel): '
    select OPT in $(fp $1); do
        if [[ $OPT =~ [0-9]$ ]]; then
            cmd=$(ps -p ${OPT##* } -o command|tail -n 1)
            if [[ "$cmd" =~ "Contents/MacOS" ]] && [[ -f /usr/local/bin/quit ]]; then
                echo "Quitting ${OPT%%:*}"
                cmd=$(echo "$cmd"| sed -E 's/.*\/(.*)\.app\/.*/\1/')
                /usr/local/bin/quit -n "$cmd"
            else
                echo "killing ${OPT%%:*}"
                kill ${OPT##* }
            fi
        fi
        break
    done
    unset IFS
}

# Show all mysql grants and (hashed) passwords.
# From http://serverfault.com/questions/8860/how-can-i-export-the-privileges-from-mysql-and-then-import-to-a-new-server
mygrants()
{
  mysql -B -N $@ -e "SELECT DISTINCT CONCAT(
    'SHOW GRANTS FOR \'', user, '\'@\'', host, '\';'
    ) AS query FROM mysql.user" | \
  mysql $@ | \
  sed 's/\(GRANT .*\)/\1;/;s/^\(Grants for .*\)/## \1 ##/;/##/{x;p;x;}'
}


# Automatically added by Platform.sh CLI installer
export PATH="/Users/jack/.platformsh/bin:$PATH"
. '/Users/jack/.platformsh/shell-config.rc' 2>/dev/null
