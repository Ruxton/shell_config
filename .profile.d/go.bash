# gocross: Cross compile for 32/64bit Windows, Linux & OSX $1=name_of_output
function gocross() {
  NAME=$1
  echo
  echo "[64 bit builds]"
  echo "Building Windows.."
  GOOS=windows GOARCH=386 go build -o pkg/${NAME}32.exe
  echo "Building Linux.."
  GOOS=linux GOARCH=386 go build -o pkg/${NAME}32.linux
  echo "Building OSX.."
  GOOS=darwin GOARCH=386 go build -o pkg/${NAME}32.osx

  echo
  echo "[64 bit builds]"
  echo "Building Windows.."
  GOOS=windows GOARCH=amd64 go build -o pkg/${NAME}64.exe
  echo "Building Linux.."
  GOOS=linux GOARCH=amd64 go build -o pkg/${NAME}64.linux
  echo "Building OSX.."
  GOOS=darwin GOARCH=amd64 go build -o pkg/${NAME}64.osx

  echo
  echo "done."
}
