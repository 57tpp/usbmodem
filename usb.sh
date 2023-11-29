#!/bin/bash
read -p "Enter your APN: " new_apn
read -p "Enter your username: " new_username
read -p "Enter your password: " new_password


cat <<EOF > /etc/wvdial.conf
[Dialer Defaults]
Phone = *99***1#
APN = $new_apn
Username = $new_username
Password = $new_password
New PPPD = yes
Stupid Mode = yes
Init1 = ATZ
Init2 = AT+CGDCONT=1,"IP","$new_apn"
Init3 = ATQ0 V1 E1 S0=0 &C1 &D2 +FCLASS=0
Dial Attempts = 3
Modem Type = Analog Modem
Modem = /dev/ttyUSB1
Dial Command = ATD
Baud = 460800
ISDN = 0
Carrier Check = no
EOF

cat <<EOF > /etc/udev/rules.d/99-usbmodem.rules
ATTRS{idVendor}=="1004", ATTRS{idProduct}=="6367", RUN+="/usr/bin/eject /dev/sr0"
ATTRS{idVendor}=="1004", ATTRS{idProduct}=="6366", RUN+="/sbin/modprobe usbserial vendor=0x1004 product=0x6366"
KERNEL=="ttyUSB*", ATTRS{../idVendor}=="1004", ATTRS{../idProduct}=="6366", ATTRS{bNumEndpoints}=="03", ATTRS{bInterfaceNumber}=="01", SYMLINK+="ttyUSBModem", GROUP="usb", TAG+="systemd", ENV{SYSTEMD_WANTS}="usbmodem.service"
EOF

cat <<EOF > /etc/systemd/system/usbmodem.service
[Unit]
Description = USBModem Service
Requires = dev-ttyUSBModem.device
After = dev-ttyUSBModem.device

[Service]
Type = simple
Restart = always
ExecStart = /usr/bin/wvdial
EOF

echo "Please reboot your system"
echo "Do "sudo ifconfig wlan0 down" if necessary"
