# clipl: Count the number of lines currently in clipboard
alias clipl="pbpaste | wc -l"

# clipw: Count the number of words currently in cipboard
alias clipw="pbpaste | wc -w"

# clipsort: Sort the lines of text in the clipboard and copy it back in"
alias clipsort="pbpaste | sort | pbcopy"

# cliprev: Reverse each line of text in the clipboard and copy it back in"
alias cliprev="pbpaste | rev | pbcopy"

# cliptidy: Tidy up HTML in the clipboard and copy it back in
alias cliptidy="pbpaste | tidy | pbcopy"
