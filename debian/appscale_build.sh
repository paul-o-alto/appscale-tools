#!/bin/bash

export DIST=`lsb_release -c -s`

cd `dirname $0`/..

echo "Installing AppScale tools on ${DIST}."

# Install the deb packages specified for this distro.
if [ -f ./debian/control.${DIST} ]; then
    PACKAGES=$(find debian -regex ".*\/control\.${DIST}\$" -exec awk -f debian/package-list.awk {} +)
    apt-get update
    apt-get install -y --force-yes ${PACKAGES}
    if [ $? -ne 0 ]; then
        echo "Failed to install deb packages for ${DIST}."
        exit 1
    fi
fi

# These system packages are too old for google-api-python-client>=1.5.0.
case ${DIST} in
    precise|trusty) pip install --upgrade httplib2 six ;;
esac

python2 setup.py install
if [ $? -ne 0 ]; then
    echo "Unable to complete AppScale tools installation."
    exit 1
fi

# Remove files from outdated appscale-tools installations.
OLD_FILES_EXIST=false
if [ -f /etc/profile.d/appscale-tools.sh ]; then
    OLD_FILES_EXIST=true
fi
rm -rf /usr/local/appscale-tools
rm -f /etc/profile.d/appscale-tools.sh
sed -i '/TOOLS_PATH/d' ~/.bashrc

echo "AppScale tools installation completed successfully!"
if [ ${OLD_FILES_EXIST} = true ]; then
    echo "You may need to run 'hash -r' before using the 'appscale' command."
fi
