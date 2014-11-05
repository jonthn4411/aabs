ifneq ($(ABS_DROID_BRANCH),jb4.2)

TOOLS_LIST := \
xbin/iperf \
xbin/iwconfig \
xbin/iwlist \
xbin/iwpriv \
xbin/iwspy \
xbin/iwgetid \
xbin/iwevent \
xbin/macadd \
bin/mlanutl \
bin/mlan2040coex \
bin/uaputl.exe \
bin/mlanevent.exe \
bin/sdptool \
xbin/hciconfig \
xbin/hcitool \
xbin/l2ping \
bin/hciattach \
xbin/rfcomm \
xbin/avinfo \
xbin/cpueater \
bin/i2cdetect \
bin/i2cdump \
bin/i2cset \
bin/i2cget

else

TOOLS_LIST := \
xbin/iperf \
xbin/iperf \
xbin/iwconfig \
xbin/iwlist \
xbin/iwpriv \
xbin/iwspy \
xbin/iwgetid \
xbin/iwevent \
xbin/macadd \
bin/mlanutl \
bin/mlan2040coex \
bin/uaputl.exe \
bin/mlanevent.exe

endif
