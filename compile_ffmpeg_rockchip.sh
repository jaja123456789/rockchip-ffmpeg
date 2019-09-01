## ccache manual:
### https://askubuntu.com/questions/470545/how-do-i-set-up-ccache
### https://wiki.archlinux.org/index.php/Ccache

# Install packages
sudo apt install autoconf automake build-essential cmake debhelper fakeroot git-core libass-dev libfreetype6-dev libsdl2-dev libtool libva-dev libvdpau-dev libvorbis-dev libxcb1-dev libxcb-shm0-dev libxcb-xfixes0-dev pkg-config texinfo wget zlib1g-dev

sudo apt install nasm # Version > 2.13! - older in stretch arm64, so it must be manually downloaded and installed
wget http://ftp.debian.org/debian/pool/main/n/nasm/nasm_2.14.02-1_arm64.deb
sudo dpkg -i nasm_2.14.02-1_arm64.deb

sudo apt install yasm # Version > 1.2.0! older in stretch arm64, so it must be manually downloaded and installed
wget http://ftp.debian.org/debian/pool/main/y/yasm/yasm_1.3.0-2+b1_arm64.deb
sudo dpkg -i yasm_1.3.0-2+b1_arm64.deb

sudo apt install libx264-dev # Version > 118! Newer in stretch arm64
sudo apt install libx265-dev libnuma-dev # Version > 68! Newer in stretch arm64
sudo apt install libvpx-dev # Version > 1.4.0! Newer in stretch arm64
sudo apt install libfdk-aac-dev
sudo apt install libmp3lame-dev # Version > 3.98.3! Newer in stretch arm64
sudo apt install libopus-dev # Version > 1.1! Newer in stretch arm64

# INFO! This is no error message!
## Make[1]: Nothing to be done for 'all'/'install'

# Compile additional packages
## Define environment variables
export FFMPEG_COMPILE_DIR="~/compile/ffmpeg"
export FFMPEG_SOURCES="${FFMPEG_COMPILE_DIR}/ffmpeg_sources"
export LIBAOM_SOURCES="${FFMPEG_COMPILE_DIR}/libaom_sources"
export MPP_SOURCES="${FFMPEG_COMPILE_DIR}/mpp_sources"
export FFMPEG_BIN="${FFMPEG_COMPILE_DIR}/ffmpeg_bin"
export LIBAOM_BIN="${FFMPEG_COMPILE_DIR}/libaom_bin"
export FFMPEG_BUILD="${FFMPEG_COMPILE_DIR}/ffmpeg_build"
export LIBAOM_BUILD="${LIBAOM_SOURCES}/aom_build"
export PKG_CONFIG_PATH="${FFMPEG_BUILD}/lib/pkgconfig"

## Create directories for sources and build files
mkdir -p ${FFMPEG_COMPILE_DIR} ${FFMPEG_SOURCES} ${LIBAOM_SOURCES} ${MPP_SOURCES} ${FFMPEG_BIN} ${LIBAOM_BIN} ${FFMPEG_BUILD} ${LIBAOM_BUILD} ${PKG_CONFIG_PATH}

## libaom
export BUILD_START_TIME=$(date +%Y-%m-%d_%H:%M:%S) && \
cd ${LIBAOM_SOURCES} && \
if [ ! -d aom ]; then git clone --depth 1 https://aomedia.googlesource.com/aom ; fi && \
cd aom && \
git pull && \
cd ${LIBAOM_SOURCES}/aom_build && \
PATH="${LIBAOM_BIN}:$PATH" cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="${LIBAOM_BUILD}" -DENABLE_SHARED=off -DENABLE_NASM=on ../aom >${LIBAOM_SOURCES}/log-cmake-${BUILD_START_TIME}.txt 2>&1 & \
disown && \
cd ${LIBAOM_SOURCES} && \
tail -f ${LIBAOM_SOURCES}/log-cmake-${BUILD_START_TIME}.txt

############## Is done when message is: ###############
######-- Build files have been written to: <dir> ######
#######################################################

export BUILD_START_TIME=$(date +%Y-%m-%d_%H:%M:%S) && \
cd ${LIBAOM_SOURCES}/aom_build && \
PATH="${LIBAOM_BIN}:$PATH" make >${LIBAOM_SOURCES}/log-make-${BUILD_START_TIME}.txt 2>&1 & \
disown && \
cd ${LIBAOM_SOURCES} && \
tail -f ${LIBAOM_SOURCES}/log-make-${BUILD_START_TIME}.txt

############## Is done when message is: ################
########## [100%] Built target simple_encoder ##########
########################################################

### make install must be done, so that ffmpeg can find all libs
export BUILD_START_TIME=$(date +%Y-%m-%d_%H:%M:%S) && \
cd ${LIBAOM_SOURCES}/aom_build && \
make install >${LIBAOM_SOURCES}/log-make-install-${BUILD_START_TIME}.txt 2>&1 & \
disown && \
cd ${LIBAOM_SOURCES} && \
tail -f ${LIBAOM_SOURCES}/log-make-install-${BUILD_START_TIME}.txt

### Change permissions and copy the built file to the lib path, which is configured for the compiler
chmod 755 ${LIBAOM_BUILD}/aom.pc && cp ${LIBAOM_BUILD}/aom.pc ${PKG_CONFIG_PATH}

## mpp (Media Process Platform MPP for Rockchip)
### Note: Check which branch has current changes
export BUILD_START_TIME=$(date +%Y-%m-%d_%H:%M:%S) && \
cd ${MPP_SOURCES} && \
if [ ! -d mpp ]; then git clone https://github.com/rockchip-linux/mpp.git ; fi && \
cd mpp && \
git pull && \
cmake -DRKPLATFORM=ON -DHAVE_DRM=ON >${MPP_SOURCES}/log-cmake-${BUILD_START_TIME}.txt 2>&1 & \
disown && \
cd ${MPP_SOURCES}/ && \
tail -f ${MPP_SOURCES}/log-cmake-${BUILD_START_TIME}.txt

############## Is done when message is: ################
###### -- Build files have been written to: <dir> ######
########################################################

export BUILD_START_TIME=$(date +%Y-%m-%d_%H:%M:%S) && \
cd ${MPP_SOURCES}/mpp && \
make >${MPP_SOURCES}/log-make-${BUILD_START_TIME}.txt 2>&1 & \
disown && \
cd ${MPP_SOURCES} && \
tail -f ${MPP_SOURCES}/log-make-${BUILD_START_TIME}.txt

############## Is done when message is: ###############
############## [100%] Built target mpi_test ###########
#######################################################

### make install must be done with sudo, so that ffmpeg can find all libs
export BUILD_START_TIME=$(date +%Y-%m-%d_%H:%M:%S) && \
cd ${MPP_SOURCES}/mpp && \
sudo make install && \
cd ..

### Change permissions and copy the built file to the lib path, which is configured for the compiler
chmod 755 ${MPP_SOURCES}/mpp/rockchip_mpp.pc ${MPP_SOURCES}/mpp/rockchip_vpu.pc && cp ${MPP_SOURCES}/mpp/rockchip_mpp.pc ${MPP_SOURCES}/mpp/rockchip_vpu.pc ${PKG_CONFIG_PATH}

# Compile ffmpeg:
export BUILD_START_TIME=$(date +%Y-%m-%d_%H:%M:%S) && \
cd ${FFMPEG_SOURCES} && \
if [ ! -d ffmpeg ]; then git clone https://gitlab.com/stevog/ffmpeg-rockchip.git ; fi && \
cd ffmpeg && \
git checkout rockchip-ffmpeg-stevog/release/4.2 && \
git pull && \
cp ${PKG_CONFIG_PATH}/* ${FFMPEG_SOURCES}/ffmpeg && \
cp ${PKG_CONFIG_PATH}/* ${FFMPEG_BIN} && \
PATH="${FFMPEG_BIN}:$PATH" ./configure \
  --prefix="${FFMPEG_BUILD}" \
  --pkg-config-flags="--static" \
  --extra-cflags="-I${FFMPEG_BUILD}/include" \
  --extra-ldflags="-L${FFMPEG_BUILD}/lib" \
  --extra-libs="-lpthread -lm" \
  --bindir="${FFMPEG_BIN}" \
  --enable-gpl \
  --enable-libaom \
  --enable-libass \
  --enable-libfdk-aac \
  --enable-libfreetype \
  --enable-libmp3lame \
  --enable-libopus \
  --enable-libvorbis \
  --enable-libvpx \
  --enable-libx264 \
  --enable-rkmpp \
  --enable-version3 \
  --enable-libdrm \
  --enable-libx265 \
  --enable-nonfree >${FFMPEG_SOURCES}/log-configure-${BUILD_START_TIME}.txt 2>&1 & \
disown && \
cd ${FFMPEG_SOURCES} && \
tail -f ${FFMPEG_SOURCES}/log-configure-${BUILD_START_TIME}.txt

############### Is done when message is: ###############
####### License: nonfree and unredistributable #########
########################################################
################# or when message is: ##################
################# <file> is unchanged ##################

export BUILD_START_TIME=$(date +%Y-%m-%d_%H:%M:%S) && \
cd ${FFMPEG_SOURCES}/ffmpeg && \
PATH="${FFMPEG_BIN}:$PATH" make >${FFMPEG_SOURCES}/log-make-${BUILD_START_TIME}.txt 2>&1 & \
disown && \
cd ${FFMPEG_SOURCES} && \
tail -f ${FFMPEG_SOURCES}/log-make-${BUILD_START_TIME}.txt

sudo cp ${FFMPEG_SOURCES}/ffmpeg/ffmpeg ${FFMPEG_SOURCES}/ffmpeg/ffprobe /usr/lib/jellyfin-ffmpeg/
sudo cp ${FFMPEG_SOURCES}/ffmpeg/ffmpeg ${FFMPEG_SOURCES}/ffmpeg/ffprobe /usr/local/bin

############### Is done when message is: ###############
############### LD      ffprobe_g ######################
############### STRIP   ffprobe ########################

##TODO man page configuration
##echo "MANPATH_MAP $HOME/bin $HOME/ffmpeg_build/share/man" >> ~/.manpath

# Delete all packages, which were needed for compiling, if you don't need them anymore
## sudo apt-get autoremove autoconf automake build-essential cmake git-core libass-dev libfreetype6-dev libmp3lame-dev libnuma-dev libopus-dev libsdl2-dev libtool libva-dev libvdpau-dev libvorbis-dev libvpx-dev libx264-dev libx265-dev libxcb1-dev libxcb-shm0-dev ibxcb-xfixes0-dev mercurial texinfo wget zlib1g-dev
