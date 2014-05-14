# txt_data_merge: $1 = template, $2 = csv
function txt_data_merge() {
  template=$1
  datafile=$2
  cat $datafile | while IFS=, read name_in code_in
  do
    echo "---- BEGIN OUTPUT FOR $name_in ----"
    cat $template | sed -e "s/%name%/$name_in/" -e "s/%code%/$code_in/"
    echo "---- END OUTPUT FOR $name_in ----"
  done
}