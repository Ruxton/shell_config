# bb: pass hg commands to standard bitbucket repo it will do 'hg $1 <bitbucket> $2'
function bb() { hg $1 ssh://hg@code.digitalignition.net/ruxton/$2 ; }