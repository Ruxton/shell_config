# thumbit: zip and copy recursively to usb key
function thumbit() {
  
  echo
  echo "ThumbIT Zip & Copy"
  echo
  echo "Usage:  thumbit <target>"
  echo "        thumbit --list"
  echo "        thumbit --rm"
  
  __volume_selector "selected_volume"
  local thumbitdir="/Volumes/${selected_volume}/thumbit"
    
  if [ $1 == "--list" ]
  then
    ls -l $thumbitdir/*.zip
    return 1
  fi
  
  zipf $1 $1
  if [ ! -d $thumbitdir ] && [ ! -f $thumbitdir ]
  then
    mkdir $thumbitdir
  fi  
  echo "Copying ${1} to ${selected_volume}..."
  if [ -d $thumbitdir ]
  then  
    cp -f $1.zip /Volumes/$selected_volume/thumbit/
    rm -f $1.zip
    echo "Done"
  fi
}

# unthumbit: copy from usb key and unzip
function unthumbit() {
  
  echo
  echo "UnThumbIT Copy & Unzip"
  echo  
  
  __volume_selector "selected_volume"
  local thumbitdir="/Volumes/${selected_volume}/thumbit"
  echo "Copying ${1} from ${selected_volume}..."
  if [ -d $thumbitdir ]
  then
    cp -f $thumbitdir/$1.zip ./
    unzip $1.zip
    rm -f $1.zip
    echo "Done"  
  fi
}

# thumbitrm: remove stuff from thumbit folders
function thumbitrm() {
  
  echo
  echo "ThumbIT Cleanup"
  echo
  
  __volume_selector "selected_volume"
  local thumbitdir="/Volumes/${selected_volume}/thumbit"
  
  
  
  if [ -f $thumbitdir ]
  then
    echo "Found ${1} in ${thumbitdir}"
  else
    echo "Unable to find ${1} in ${thumbitdir}"
  fi
}

# __volume_selector: For selecting volumes from /Volumes
function __volume_selector() {
    local volumes
    volumes=`ls /Volumes/`
    
    __selector "Enter a volume to select" $1 "" $volumes
}

# __dir_selector: For selecting directories from the current directory
function __dir_selector() {
  local directories
  local current_dir=`PWD`
  
  directories=`ls -C $1`
  
  __selector "Enter a directory to select" $2 "" $directories
}