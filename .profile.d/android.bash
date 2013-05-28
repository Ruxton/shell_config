# droid: (deploy/compile/run) Deploy, compile or run android projects with maven
function droid() {

  if [ $# -lt 1 ]; then
  	cat <<-EOF
Usage: droid (deploy|compile)

deploy: Deploy android project to device with maven (mvn android:deploy)
deploy: Deploy and run an android project on device with maven (mvn android:deploy android:run)
compile: Compile android project with maven (mvn clean install)
	EOF
    return 0
  fi
  ARGS=("$@")
  mvn_args=""
  for action in $ARGS; do
  	case "$action" in
  	compile)		mvn_args="$mvn_args clean install";;
		deploy)     mvn_args="$mvn_args android:deploy";;
		run)        mvn_args="$mvn_args android:deploy android:run";;
    esac
  done
  if [[ "$mvn_args" != "" ]]; then
  	mvn $mvn_args
  fi
}

# testflightup: Upload APK files from this
function testflightup() {

  # contains TESTFLIGHT_API_TOKEN & TESTFLIGHT_TEAM_TOKEN & TESTFLIGHT_DISTRIBUTION_LISTS
  source ~/.testflight

  echo
  echo "TestFlightApp Uploader"
  echo

  local notes current_date default_notes
  local notify=False
  local distribution_lists=$TESTFLIGHT_DISTRIBUTION_LISTS

  while [ "${1+defined}" ]; do
    case "$1" in
      --help)         cat <<-EOF
Usage: testflightup [options]

OPTIONS:
    --help                  See this message 
    --notify                Notify users in the default distribution list of the new version
    --note <notes>          Set the note to be set for the build
    --distribution <list>   A comma seperated list of valid distribution lists ie. "Android,Android The Place"
EOF
                      return 0
                      ;;
      --distribution) shift
                      distribution_lists=$1
                      ;;
      --notify)       notify=True
                      ;;
      --note)         shift
                      local inNotes=$1
                      ;;
    esac
    shift
  done  


  __apk_selector


  if [[ "$selected_apk" == "" ]]; then
    echo "No APK file selected, exiting."
    return 0
  fi

  current_date=`date`
  default_notes="Deployed $current_date"
 
  if [ "${inNotes+defined}" ]; then
    default_notes=$inNotes
  fi

  read -ep "Deploy notes (default $default_notes): " notes;
  notes=${notes:-$default_notes}

  curl http://testflightapp.com/api/builds.json \
    -F file=@target/$selected_apk \
    -F api_token=$TESTFLIGHT_API_TOKEN \
    -F team_token=$TESTFLIGHT_TEAM_TOKEN \
    -F notes="$notes" \
    -F notify=$notify \
    -F distribution_lists="$distribution_lists"
}

function __apk_selector() {
  if [ "$1" == "" ]
  then
    local prompt="Please select an apk"
  else
    local prompt=$1
  fi  

  local most_recent_apk=`ls target/*.apk | xargs -n1 basename | tail -n 1`
  local apk_list=`ls target/*.apk | xargs -n1 basename`

  __selector "${prompt}" "selected_apk" "" "${apk_list}"  

}