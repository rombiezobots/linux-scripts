# Blender Version Manager

install_directory='/opt/blender/'
run_directory='/usr/local/bin/'

wget -O - https://download.blender.org/release/ | echo -





xz=wget https://blender.org/download/ 2>&1 | grep -io '<a href=https://www.blender.org/download/release/*'
echo $xz
# wget $xz
# tar xf blender*.tar.xz
# rm blender*.tar.xz
# mv blender* blender
# cat blender/blender.desktop \
#   | sed -e 's@^\(Icon=\)\(.*\)@\1'"$PWD/blender/"'\2.svg@' \
#   | sed -e 's@^\(Exec=\)\(.*\)@\1'"$PWD/blender/"'\2@' \
#   > $HOME/.local/share/applications/blender.desktop
# update-desktop-database $HOME/.local/share/applications/



# wget --spider --force-html -r -l1 http://somesite.com 2>&1 | grep 'Saving to:'
