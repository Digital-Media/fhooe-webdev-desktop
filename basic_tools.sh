echo "## Installing zip, unzip, curl, net-tools ##"

sudo apt-get -y install zip unzip curl net-tools
echo "## Installing chrome -- only chromium can be installed with apt-get ##"

cd /home/ubuntu/Downloads
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i google-chrome-stable_current_amd64.deb

echo "## permanently set Screen Resolution to 1920x1080 60 to optimize YouTube streaming ##"
# Get parameters for xrandr
# cvt 1920 1080 60
# Get name of connected Screen.
# xrandr

XRANDR=/etc/X11/Xsession.d/45custom_xrandr-settings
sudo bash -c "echo 'xrandr --newmode 1920x1080_60.00  173.00  1920 2048 2248 2576  1080 1083 1088 1120 -hsync +vsync' >> $XRANDR"
sudo bash -c "echo 'xrandr --addmode Virtual1 1920x1080_60.00' >> $XRANDR"
sudo bash -c "echo 'xrandr --output Virtual1 --mode 1920x1080_60.00' >> $XRANDR"
sudo chmod +x /etc/X11/Xsession.d/45custom_xrandr-settings

echo "## adding empty document for Nautilus to Vorlagen ##"
cd $HOME/Vorlagen
touch "Leeres Document"
