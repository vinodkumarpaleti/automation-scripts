#!/bin/bash

if [ $(id -u) -ne 0 ]; then
  echo "You should be a root user to perform this command"
  exit 1
fi

yum install epel-release -y
yum install java-17-openjdk unzip -y
#URL=$(curl -s https://www.sonarqube.org/downloads/ | grep 'Community Edition' | grep sonarqube-|head -1  | sed -e "s/>/ /g"|xargs -n 1  | grep ^href | awk -F = '{print $2}')
#VERSION=$(curl -s https://binaries.sonarsource.com/Distribution/sonarqube/ | grep '.zip<' | tail -1 | sed -e 's/</ /g'  | xargs -n1 | grep ^href | sed -e 's/href=sonarqube-//' -e 's/.zip>//')
#URL="https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-${VERSION}.zip"
#URL=$(curl -s -L https://www.sonarqube.org/downloads/ | grep zip  | grep 'Community Edition' | grep 'sonarqube-8' | head -1  | awk -F '"' '{print $2}')
URL="https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-10.4.0.87286.zip"
FILENAME=$(echo $URL | awk -F / '{print $NF}')
FOLDERNAME=$(echo $FILENAME | sed -e 's/.zip//g')

id sonar &>/dev/null
if [ $? -ne 0 ]; then
  useradd sonar
fi

cd /home/sonar
pkill java
rm -rf sonarqube
curl -s -o $FILENAME $URL
unzip $FILENAME
rm -f $FILENAME
mv $FOLDERNAME sonarqube

chown sonar:sonar sonarqube -R
curl -s https://raw.githubusercontent.com/learndevopsonline/labautomation/master/tools/sonarqube/sonar.service >/etc/systemd/system/sonarqube.service
systemctl daemon-reload
systemctl enable sonarqube
sed -i -e '/^RUN_AS_USER/ d' -e '/#RUN_AS_USER/ a RUN_AS_USER=sonar' /home/sonar/sonarqube/bin/linux-x86-64/sonar.sh
systemctl start sonarqube
