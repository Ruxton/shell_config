# rc: Rails console
alias rc="rails c"

# debugme: touch tmp/debug.txt
alias debugme="touch tmp/debug.txt"

# rgm: Generate rails migrations
function rgm() {
  local fileopener file

  fileopener='atom'
  file=`rails g migration $@ | grep "create" | awk '{print $3}'`

  # open migration in netbeans
  $fileopener $file
}

# rakerealreset: Runs rake tasks: drop, create, migrate, seed
alias rakerealreset="rake db:drop rake db:create rake db:migrate rake db:seed"

# rollback: rake db:rollback db:test:prepare
alias rollback="rake db:rollback db:test:prepare"

# migrate: rake db:migrate db:test:prepare
alias migrate="rake db:migrate db:test:prepare"
