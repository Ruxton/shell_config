function droidshot() {
  local formatter="%03d"
  local file="$1"
  local n=1
  local fn=$(printf "${formatter}" $n)

  if [[ "$file" == "" ]]; then
    file="droidshot-"$(date "+%d-%m-%Y-")
    files=`ls ${file}* 2>/dev/null|awk '{print $1}'`
    ext=".png"

    for i in $files; do
      if [[ "${file}${fn}${ext}" == "${i}" ]]; then
        n=$(( n + 1 ))
      fi
      fn=$(printf "${formatter}" $n)
    done

    file="${file}${fn}${ext}"
  fi
  echo "Screenshotting to ${file}.."
  adb shell screencap -p 2> /dev/null | perl -pe 's/\x0D\x0A/\x0A/g' > $file
}

function demu() {
  avd="$1"
  if [[ "$avd" == "" ]]; then
    avd="Nexus-4.2.2"
  fi

  emulator -avd ${avd} -scale 0.5 & > /dev/null
}

# createkeystore: $1=keystore_file $2=alias
function createkeystore() {
  keytool -genkey -v -keystore $1 -alias $2 -keyalg RSA -keysize 2048 -validity 10000
}

function generate_fb_keyhash() {
  if [[ "$1" == "" ]]; then
    key_alias="androiddebugkey"
  else
    key_alias=$1
  fi

  if [[ "$2" == "" ]]; then
    key_store="~/.android/debug.keystore"
  else
    key_store=$2
  fi
  keytool -exportcert -alias androiddebugkey -keystore ~/.android/debug.keystore | openssl sha1 -binary | openssl base64
}


# droid_icon_copy: $icon_name $target
function icon_copy() {
  local icon=$1
  local resource_folders="mdpi hdpi xhdpi xxhdpi"
  echo "Looking for ${icon}.."

  for res in $resource_folders; do
    local uc_res=`echo $res|tr '[a-z]' '[A-Z]'`
    echo "Copying $uc_res to $res"
    cp $uc_res/$1.png $2/drawable-$res/$1.png
  done

}

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

# build_droid_icons: SVG 2 PNG at Droid Sizes
function build_droid_icons() {
  ICON_SIZES=(xxhdpi xhdpi hdpi mdpi)

  if [[ "$1" == "" ]]; then
    INPUT_DIR="."
  else
    INPUT_DIR=$1
  fi

  if [[ "$2" == "" ]]; then
    OUTPUT_DIR=$INPUT_DIR
  else
    OUTPUT_DIR=$2
  fi

  for (( i = 0; i < ${#ICON_SIZES[@]}; i++ )); do
    size=${ICON_SIZES[$i]}
    path="${OUTPUT_DIR}/res/drawable-${size}"
    echo "Creating directory ${path}"
    mkdir -p $path
  done
  ## Setup folders


  for f in $(find ${INPUT_DIR} -name "*.svg" -type f); do
    echo "Processing $f"
    process_droid_icon $f ${OUTPUT_DIR}
  done
}

function process_droid_icon {
  ICON_SIZES=(xxhdpi xhdpi hdpi mdpi)
  ICON_DPI=(360 180 133.75 90)
  inkscape="/Applications/Inkscape.app/Contents/Resources/bin/inkscape -z"
  file=$(basename $1)

  filename="${file/.svg}.png"

  for (( i = 0; i < ${#ICON_SIZES[@]}; i++ )); do
    echo "Processing ${ICON_SIZES[$i]}..."
    path="$2/res/drawable-${ICON_SIZES[$i]}"

    $inkscape -d ${ICON_DPI[$i]} -e $path/$filename $1 >& /dev/null
  done
}

# adbrestart: restart Android Debug Bridge
function adbrestart() {
  $ANDROID_HOME/platform-tools/adb kill-server
  $ANDROID_HOME/platform-tools/adb start-server
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
