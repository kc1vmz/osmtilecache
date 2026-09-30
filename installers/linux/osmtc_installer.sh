#!/bin/bash
# OSM Tile Cache Installer
# Copyright (c) 2026 John Rokicki KC1VMZ
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
#
# http://www.kc1vmz.com
# 
OSMTC_UPGRADE=N
OSMTC_OS=$(uname)
if [ "$OSMTC_OS" = "Linux" ]; then
  echo "Welcome to the OSM Tile Cache installer for Linux"
  echo "Copyright (c) 2026 John Rokicki KC1VMZ - Licensed under GPL v3"
  echo "https://www.kc1vmz.com"

  if grep -q OSMTC_INSTALL_DIR /etc/environment; then
    echo "A previous version of OSM Tile Cache was detected."
    OSMTC_UPGRADE=Y
    read -e -i $OSMTC_UPGRADE -p "Do you wish to upgrade OSM Tile Cache?: " OSMTC_UPGRADE
    if [[ "$OSMTC_UPGRADE" =~ ^[Nn]$ ]]; then
      echo "OSM Tile Cache installation will now exit."
      exit 1
    fi
  fi

  # default environment variables
  OSMTC_VERSION=0.0.1
  OSMTC_INSTALL_DIR=~/osmtc
  OSMTC_DB_DIR=~/osmtc/db
  OSMTC_TEMP_DIR=~/osmtc/tmp
  OSMTC_PORT=8080
  OSMTC_INSTALL_SERVICES=Y

  if [[ "$OSMTC_INSTALL_SERVICES" =~ ^[Yy]$ ]]; then
    read -e -i $OSMTC_VERSION -p "What version of OSM Tile Cache?: " OSMTC_VERSION
    if [[ "$OSMTC_UPGRADE" =~ ^[Nn]$ ]]; then
      read -e -i $OSMTC_INSTALL_DIR -p "Where should OSM Tile Cache be installed?: " OSMTC_INSTALL_DIR
      read -e -i $OSMTC_DB_DIR -p "Where should OSM Tile Cache database space be located?: " OSMTC_DB_DIR
      read -e -i $OSMTC_TEMP_DIR -p "Where should OSM Tile Cache temp space be located?: " OSMTC_TEMP_DIR
      read -e -i $OSMTC_PORT -p "What port should the HTTP service listen on?: " OSMTC_PORT
      read -e -i $OSMTC_INSTALL_SERVICES -p "Do you want OSM Tile Cache to be configured as services and started at boot time (Y/n)?: " OSMTC_INSTALL_SERVICES
    else
      OSMTC_INSTALL_DIR=$(grep "^OSMTC_INSTALL_DIR=" /etc/environment | sed 's/^OSMTC_INSTALL_DIR=//' | tr -d '"')
      OSMTC_INSTALL_DIR=$OSMTC_INSTALL_DIR
    fi
  fi

  sudo cp /etc/environment /etc/environment.pre_osmtc_install

  JAVA_VER=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}' | awk -F '.' '{sub("^$", "0", $2); print $1$2}')
  if [ "$JAVA_VER" -ge 21 ]; then
    # fall through
    echo "Java 21+ verified"
  else
    echo "Java 21 or greater not installed - exiting."
    sudo rm /etc/environment.pre_osmtc_install
    exit 1
  fi

  OSMTC_INSTALL_DIR=$OSMTC_INSTALL_DIR
  if [[ "$OSMTC_UPGRADE" =~ ^[Nn]$ ]]; then
    echo "OSMTC_INSTALL_DIR=$OSMTC_INSTALL_DIR" | sudo tee -a /etc/environment >  /dev/null
    mkdir $OSMTC_INSTALL_DIR
    sudo mkdir $OSMTC_TEMP_DIR
    sudo chown $USER $OSMTC_TEMP_DIR
    sudo mkdir $OSMTC_DB_DIR
    sudo chown $USER $OSMTC_DB_DIR
  fi

  echo "Retrieving OSM Tile Cache binary"
  cd $OSMTC_INSTALL_DIR
  OSMTC_SRC_URL_ROOT=https://github.com/kc1vmz/osmtilecache/releases/download/v$OSMTC_VERSION
  wget -q -O osmtilecache-$OSMTC_VERSION.jar $OSMTC_SRC_URL_ROOT/osmtilecache-$OSMTC_VERSION.jar
  OSMTC_SRC_URL_ROOT=

  chmod +x osmtilecache-$OSMTC_VERSION.jar

  if [[ "$OSMTC_UPGRADE" =~ ^[Nn]$ ]]; then
    OSMTC_DB_DIR=$OSMTC_DB_DIR
    OSMTC_TEMP_DIR=$OSMTC_TEMP_DIR
    OSMTC_PORT=$OSMTC_PORT
  else
    if [ -n "/etc/systemd/system/osmtilecache.service+x" ]; then
      OSMTC_INSTALL_SERVICES=Y
    else
      OSMTC_INSTALL_SERVICES=N
    fi
  fi

  if [[ "$OSMTC_INSTALL_SERVICES" =~ ^[Yy]$ ]]; then
    if [[ "$OSMTC_UPGRADE" =~ ^[Nn]$ ]]; then
      echo '[Unit]' | sudo tee -a /etc/systemd/system/osmtilecache.service >  /dev/null
      echo 'Description=OSM Tile Cache' | sudo tee -a /etc/systemd/system/osmtilecache.service >  /dev/null
      echo '[Service]' | sudo tee -a /etc/systemd/system/osmtilecache.service >  /dev/null
      echo 'User='$LOGNAME | sudo tee -a /etc/systemd/system/osmtilecache.service >  /dev/null
      echo 'WorkingDirectory='$OSMTC_INSTALL_DIR | sudo tee -a /etc/systemd/system/osmtilecache.service >  /dev/null
      echo 'Type=simple' | sudo tee -a /etc/systemd/system/osmtilecache.service >  /dev/null
      echo 'Restart=always' | sudo tee -a /etc/systemd/system/osmtilecache.service >  /dev/null
      echo 'SuccessExitStatus=143' | sudo tee -a /etc/systemd/system/osmtilecache.service >  /dev/null
      echo 'RemainAfterExit=yes' | sudo tee -a /etc/systemd/system/osmtilecache.service >  /dev/null
      echo 'ExecStart=java -jar '$OSMTC_INSTALL_DIR'/osmtilecache-'$OSMTC_VERSION'.jar' | sudo tee -a /etc/systemd/system/osmtilecache.service >  /dev/null
      echo 'Environment=OSMTC_DB_DIR='$OSMTC_DB_DIR | sudo tee -a /etc/systemd/system/osmtilecache.service >  /dev/null
      echo 'Environment=OSMTC_TEMP_DIR='$OSMTC_TEMP_DIR | sudo tee -a /etc/systemd/system/osmtilecache.service >  /dev/null
      echo 'Environment=SERVER_PORT='$OSMTC_PORT | sudo tee -a /etc/systemd/system/osmtilecache.service >  /dev/null
      echo 'Environment=OSMTC_INSTALL_DIR='$OSMTC_INSTALL_DIR | sudo tee -a /etc/systemd/system/osmtilecache.service >  /dev/null
      echo '[Install]' | sudo tee -a /etc/systemd/system/osmtilecache.service >  /dev/null
      echo 'WantedBy=multi-user.target' | sudo tee -a /etc/systemd/system/osmtilecache.service >  /dev/null
      sudo systemctl daemon-reload
      sudo systemctl enable osmtilecache
      sudo systemctl start osmtilecache
      echo "OSM Tile Cache running as background service."
    else
      sudo systemctl stop osmtilecache
      sudo sed -i 's/osmtilecache-.*.jar/osmtilecache-'$OSMTC_VERSION'.jar/g' /etc/systemd/system/osmtilecache.service
      sudo systemctl daemon-reload
      sudo systemctl start osmtilecache
      echo "OSM Tile Cache restarted."
    fi
  else
    echo "Environment variables have been added to /etc/environment.  Make sure to reboot or run 'source /etc/environment' to add them into any new terminal."
    echo "You can run OSM Tile Cache using the  'java -jar $OSMTC_INSTALL_DIR/osmtilecache-$OSMTC_VERSION.jar' command"
  fi

  # cleanup environment
  OSMTC_INSTALL_DIR=
  OSMTC_TEMP_DIR=
  OSMTC_VERSION=
  OSMTC_INSTALL_SERVICES=
  OSMTC_DB_DIR=
  OSMTC_PORT=
  OSMTC_UPGRADE=
elif [ "$OSMTC_OS" = "Darwin" ]; then
  echo "This is a Mac Machine - not yet supported"
  exit 1
else
  echo "Unsupported OS -" $OSMTC_OS
  exit 1
fi

echo "OSM Tile Cache installation complete."