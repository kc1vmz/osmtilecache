#!/bin/bash
OSMTC_OS=$(uname)
if [ "$OSMTC_OS" = "Linux" ]; then
  echo "Welcome to the OSM Tile Cache UNinstaller for Linux"

  # default environment variables
  OSMTC_CONFIRM_UNINSTALL=Y

  read -e -i $OSMTC_CONFIRM_UNINSTALL -p "Do you want to uninstall OSM Tile Cache (Y/n)?: " OSMTC_CONFIRM_UNINSTALL

  if [[ "$OSMTC_CONFIRM_UNINSTALL" =~ ^[Yy]$ ]]; then
    # fall through
    echo Starting uninstall of OSM Tile Cache
  else
    #any other answer - exit
    exit 1
  fi

  echo Backing up /etc/environment
  sudo cp /etc/environment /etc/environment.pre_osmtc_uninstall

  echo Removing environment variables from /etc/environment
  sudo sed -i '/OSMTC_INSTALL_DIR/d' /etc/environment
  sudo sed -i '/OSMTC_DB_DIR/d' /etc/environment
  sudo sed -i '/OSMTC_TILES_DIR/d' /etc/environment
  sudo sed -i '/OSMTC_CONFIG/d' /etc/environment
  sudo sed -i '/OSMTC_TILE_SERVER/d' /etc/environment

  echo Removing services
  sudo systemctl stop osmtilecache
  sudo systemctl disable osmtilecache
  sudo rm /etc/systemd/system/osmtilecache.service
  sudo systemctl daemon-reload

  if [ -n "${OSMTC_INSTALL_DIR+x}" ]; then
    echo Deleting OSM Tile Cache application
    sudo rm osmtilecache*.jar
    echo Not deleting ${OSMTC_INSTALL_DIR} - delete independently.
  else
    echo OSM Tile Cache installation directory unknown - delete independently.
  fi

  if [ -n "${OSMTC_TEMP_DIR+x}" ]; then
    echo Not deleting ${OSMTC_TEMP_DIR} - delete independently.
  else
    echo OSM Tile Cache temporary directory unknown - delete independently.
  fi

  if [ -n "${OSMTC_DB_DIR+x}" ]; then
    echo Not deleting ${OSMTC_DB_DIR} - delete independently.
  else
    echo OSM Tile Cache database directory unknown - delete independently.
  fi

  if [ -n "${OSMTC_TILES_DIR+x}" ]; then
    echo Not deleting ${OSMTC_TILES_DIR} - delete independently.
  else
    echo OSM Tile Cache tiles directory unknown - delete independently.
  fi

  OSMTC_CONFIRM_UNINSTALL=

elif [ "$OSMTC_OS" = "Darwin" ]; then
  echo "This is a Mac Machine - not yet supported"
  exit 1
else
  echo "Unsupported OS -" $OSMTC_OS
  exit 1
fi

echo "OSM Tile Cache uninstallation complete."