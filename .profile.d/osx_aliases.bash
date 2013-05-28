# rm_DS_Store: removes all .DS_Store file from the current dir and below
alias rm_DS_Store='find . -name .DS_Store -exec rm {} \;'

# cdf: cd's to frontmost window of Finder
cdf ()
{
    currFolderPath=$( /usr/bin/osascript <<"    EOT"
        tell application "Finder"
            try
                set currFolder to (folder of the front window as alias)
            on error
                set currFolder to (path to desktop folder as alias)
            end try
            POSIX path of currFolder
        end tell
    EOT
    )
    echo "cd to \"$currFolderPath\""
    cd "$currFolderPath"
}

alias cvlc="/Applications/VLC.app/Contents/MacOS/VLC -I rc"