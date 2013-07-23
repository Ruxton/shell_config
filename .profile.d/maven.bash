
function mvn_push() {
  local host='mrhorse.digitalignition.net'
  local remotepath='~/maven/'
  local artifact=`basename $1`
  local artifact_path=$1
  local groupid=''
  local artifactid=''
  local version='0.1'
  local lastupdated=`date +"%Y%m%d%H%M%S"`
  local extension="${artifact_path##*.}"

  read -ep "Group ID (default $groupid): " groupid;
  read -ep "Artifact ID (default $artifactid): " artifactid;
  read -ep "Version (default $version): " version;

  scp $artifact_path $host:~

  local newremotepath="${remotepath}${groupid/.//}/${artifactid}/${version}/"

  ssh $host "mkdir -p ${newremotepath};
  cd ${newremotepath}

  pom=\"<?xml version=\\\"1.0\\\" encoding=\\\"UTF-8\\\"?>\\n
<project xsi:schemaLocation=\\\"http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd\\\" xmlns=\\\"http://maven.apache.org/POM/4.0.0\\\" xmlns:xsi=\\\"http://www.w3.org/2001/XMLSchema-instance\\\">\\n
\\t<modelVersion>4.0.0</modelVersion>\\n
\\t<groupId>${groupid}</groupId>\\n
\\t<artifactId>${artifactid}</artifactId>\\n
\\t<version>${version}</version>\\n
</project>\"

  echo -e \$pom > ${artifactid}-${version}.pom;
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

    for versionStr in \$versions;do if [[ \"\$versionStr\" != $version ]]; then xml+=\"\\t\\t\\t<version>\$versionStr</version>\\n\"; fi; done;

    xml+=\"\\t\\t</versions>\\n
    \\t\\t<lastUpdated>${lastupdated}</lastUpdated>\\n
  \\t</versioning>\\n
</metadata>\\n\";
  echo -e \$xml > maven-metadata.xml;
  md5sum maven-metadata.xml | awk '{ print \$1 }' > maven-metadata.xml.md5;
  sha1sum maven-metadata.xml | awk '{ print \$1 }' > maven-metadata.xml.sha1"
}