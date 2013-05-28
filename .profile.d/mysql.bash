# dumptocsv: mysqldump to csv
dumptocsv() {
  mysqldump -u $1 -p -t -T$3 $2 --fields-enclosed-by=\" --fields-terminated-by=,
}