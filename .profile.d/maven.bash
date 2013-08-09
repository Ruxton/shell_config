# mvn_push: Push resource to configured maven repo
function mvn_push() {
  ## Expects that you're serving http://$host/ as the entire maven repo from $remotepath
  local host='maven.digitalignition.net' # change to a server you can SCP to
  local remotepath='~/maven/' # change to a path

  # No filename provided, send back usage
  if [ $# -lt 1 ]; then
    cat <<-EOF
$(tput bold)usage:$(tput sgr0) mvn_push <filename> (--with-pom)
--with-pom: Will try to get the pom from ../pom.xml

EOF
    return 1
  fi

  ## setup local vars, don't change these, they're defaults
  local artifact=`basename $1`
  local artifact_path=$1
  local groupid=''
  local artifactid=''
  local version='0.1'
  local lastupdated=`date +"%Y%m%d%H%M%S"`
  local extension="${artifact_path##*.}"

  if [[ "$2" == "--with-pom" ]]; then
    echo "$(tput bold) Using POM from file system $(tput sgr0)"
    groupid=`xpath $3 "//project/groupId/text()" 2> /dev/null`
    if [[ "$groupid" == "" ]]; then
      groupid=`xpath $3 "//project/parent/groupId/text()" 2> /dev/null`
    fi
    artifactid=`xpath $3 "//project/artifactId/text()" 2> /dev/null`
    version=`xpath $3 "//project/version/text()" 2> /dev/null`
    if [[ "$version" == "" ]]; then
      version=`xpath $3 "//project/parent/version/text()" 2> /dev/null`
    fi
    pom=`cat $3`
  else
    pom="<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n
      <project xsi:schemaLocation=\"http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd\" xmlns=\"http://maven.apache.org/POM/4.0.0\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\">\n
      \t<modelVersion>4.0.0</modelVersion>\n
      \t<groupId>${groupid}</groupId>\n
      \t<artifactId>${artifactid}</artifactId>\n
      \t<version>${version}</version>\n
      </project>"
  fi

  read -ep "Group ID (default $groupid): " ingroupid;
  read -ep "Artifact ID (default $artifactid): " inartifactid;
  read -ep "Version (default $version): " inversion;

  groupid=${ingroupid:-$groupid}
  artifactid=${inartifactid:-$artifactid}
  version=${inversion:-$version}

  scp $artifact_path $host:~

  local newremotepath="${remotepath}${groupid//.//}/${artifactid}/${version}/"

  ssh $host "mkdir -p ${newremotepath};
  cd ${newremotepath}

  echo -e '${pom}' > ${artifactid}-${version}.pom;
  mv ~/${artifact} ./${artifactid}-${version}.${extension};
  md5sum ./${artifactid}-${version}.${extension} | awk '{ print \$1 }' > ./${artifactid}-${version}.${extension}.md5;
  sha1sum ./${artifactid}-${version}.${extension} | awk '{ print \$1 }' > ./${artifactid}-${version}.${extension}.sha1;
  md5sum ./${artifactid}-${version}.pom | awk '{ print \$1 }' > ./${artifactid}-${version}.pom.md5;
  sha1sum ./${artifactid}-${version}.pom | awk '{ print \$1 }' > ./${artifactid}-${version}.pom.sha1"

  ssh $host "cd ${newremotepath}../;
    versions=\`find * -maxdepth 0 -type d\`;
    xml=\"<metadata>\\n
\\t<groupId>${groupid}</groupId>\\n
\\t<artifactId>${artifactid}</artifactId>\\n
\\t<versioning>\\n
\\t\\t<release>${version}</release>\\n
\\t\\t<versions>\\n
\\t\\t\\t<version>${version}</version>\\n\";

    for versionStr in \$versions;do if [[ \"\$versionStr\" != \"${version}\" ]]; then xml+=\"\\t\\t\\t<version>\$versionStr</version>\\n\"; fi; done;

    xml+=\"\\t\\t</versions>\\n
    \\t\\t<lastUpdated>${lastupdated}</lastUpdated>\\n
  \\t</versioning>\\n
</metadata>\\n\";
  echo -e \$xml > maven-metadata.xml;
  md5sum maven-metadata.xml | awk '{ print \$1 }' > maven-metadata.xml.md5;
  sha1sum maven-metadata.xml | awk '{ print \$1 }' > maven-metadata.xml.sha1"

  echo "$(tput setaf 2)Successfully completed$(tput sgr0)"
  echo "Group: $groupid"
  echo "Artifact: $artifactid"
  echo "Version: $version"
  echo "URL: http://${host}/${groupid//.//}/${artifactid}/${version}/"

  dependency="<dependency>\n
\t<groupId>$groupid</groupId>\n
\t<artifactId>$artifactid</artifactId>\n
\t<version>$version</version>\n
\t<type>$extension</type>\n
</dependency>"

  echo -e $dependency

  return 0
}