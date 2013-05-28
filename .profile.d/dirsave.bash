# sdirs: source the ~/.dirs
alias sdirs='source ~/.dirs' 

# show: show all stored directories
alias show='cat ~/.dirs|grep "^.*="'

# save: save current directory under alias eg. save <alias> stores the current dir under that alias
save () { /usr/bin/sed "/$@/d" ~/.dirs > ~/.dirs1; \mv ~/.dirs1 ~/.dirs; echo "DIR_$@"=\"`pwd`\" >> ~/.dirs; source ~/.dirs ; }

# cdd: change to a saved directory
function cdd() { sdirs; cd $(eval $(echo echo $(echo \$DIR_$1))) ; }

#sdirs