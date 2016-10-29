#! /bin/bash
#ARPiE Config Tool

#Validates switch 1 which is for Press Name
if [[ ! $1 ]]; then
	echo "No Device Name Set"
	exit 1
fi

#Validates switch 2 which is for CPU Core Count
if [[ ! $2 ]]; then
	echo "CPU Core Count Not Defined"
	exit 1
fi

#Validates CPU Core Count is a numerical value
if [[ "$2" =~ ^[0-9]+$ ]]; then
	sleep 0
else
	echo "Core Count is not a valid Integer"
	exit 1
fi

#Validates the CPU Core Count is between 1 and 4

if [[ $2 -ge 1 && $2 -le 4 ]]; then
	echo "Core Count Value Validated"
else
	echo "Core Count must be between 1 and 4"
	exit 1
fi

#Validates switch 3 which is for carrier selection
if [[ ! $3 ]]; then
	echo "No Carrier Selection Specified"
	exit 1
fi

#Validates Carrier Selection is valid carrier
if [[ $3 = "ATT" ]]; then
	echo "Carrier:"$3" Validated"
elif [[ $3 = "AATT" ]]; then
	echo "Carrier"$3" Validated"
elif [[ $3 = "A" ]]; then
	echo "Carrier"$3" Validated"
elif [[ $3 = "IO" ]]; then
	echo "Carrier:"$3" Validated"
else
	echo "Carrier Selection is not a valid Carrier Option."
	exit 1
fi

devicefile="/home/pi/ARPiE/Config/devicename.cfg"
corefile="/home/pi/ARPiE/Config/corecount.cfg"
carrierfile="/home/pi/ARPiE/Config/carrier.cfg"
if [[ -e $devicefile ]]; then
	rm $devicefile
fi
echo $1 >> "$devicefile"
if [[ -e $corefile ]]; then
	rm $corefile
fi
echo $2 >> "$corefile"
if [[ -e $carrierfile ]]; then
	rm $carrierfile
fi
echo $3 >> "$carrierfile"

#Remove outdated files if update is running
configlog="/home/pi/ARPiE/Logs/config.log"
if [[ -e $configlog ]]; then
	sudo rm /home/pi/ARPiE/Config/hostapd
	sudo rm /home/pi/ARPiE/Config/hostapd.conf
	sudo rm /home/pi/ARPiE/Config/hosts
	sudo rm /home/pi/ARPiE/Config/hostname
	sudo rm /home/pi/ARPiE/Config/dhcpcd.conf
	sudo rm /home/pi/ARPiE/Config/dnsmasq.conf
	sudo rm /home/pi/ARPiE/Config/interfaces
	sudo rm /home/pi/ARPiE/Config/wvdial.conf
	sudo rm /home/pi/ARPiE/Config/crontab
	sudo rm /home/pi/ARPiE/Config/sudo_crontab
	sudo rm /home/pi/ARPiE/Config/cmdline.txt
	crontab -r
	sudo crontab -r
	echo "Date:"$( date )" - Starting Reconfiguration for Device:"$1" - Active Cores:"$2" - On Cellular Network:"$3 >> "$configlog"
else
	touch $configlog
	echo "Date:"$( date )" - Starting Configuration for Device:"$1" - Active Cores:"$2" - On Cellular Network:"$3 >> "$configlog"

fi
#Load options into variables
devicename="$1"
corecount="$2"
carrier="$3"
clear
#Prompt user to configure device if update did not initialize config
echo "Continueing will configure this arms reach device with the following settings"
echo "Device Name:"$devicename
echo "Active Cores:"$corecount
echo "Wireless Carrier:"$carrier
echo "Are you sure you want to continue (Y/N)?"
update="/home/pi/ARPiE/Logs/updating.cfg"
if [[ ! -e $update ]]; then
	answer=
	while [[ ! $answer ]]; do
		read -r -n 1 -s answer
		if [[ $answer = [Yy] ]]; then
			clear
			echo "Beginning Configuration."
			sleep 1s
			clear 
			echo "Beginning Configuration.."
			sleep 1s
			clear
			echo "Beginning Configuration..."
			sleep 1s
		elif [[ $answer = [Nn] ]]; then
			exit 1
		fi
	done
fi
echo "Date:"$( date )" - Starting Configuration"

#Set hostname as devicename
echo "Date:"$( date )" - Starting Hostname Configuration" >> "$configlog"
echo 'Setting Hostname To '$devicename'.'
file="/home/pi/ARPiE/Config/hostname"
tofile="/etc/hostname"
touch $file
echo $devicename >> "$file"
sudo cp $file $tofile
echo 'Configuring Hosts File For '$devicename'.'
echo "Date:"$( date )" - Hostname Configuration Complete" >> "$configlog"

#Set hosts devicename
echo "Date:"$( date )" - Starting Hosts Configuration" >> "$configlog"
file="/home/pi/ARPiE/Config/hosts"
tofile="/etc/hosts"
touch $file
echo '127.0.0.1		localhost' >> "$file"
echo '::1		localhost ip6-localhost ip6-loopback' >> "$file"
echo 'ff02::1		ip6-allnodes' >> "$file"
echo 'ff02::2		ip6-allrouters' >> "$file"
echo '' >> "$file"
echo '127.0.1.1		'$devicename >> "$file"
echo '127.0.1.1		raspberrypi' >> "$file"
sudo cp $file $tofile
echo "Date:"$( date )" - Hosts Configuration Complete" >> "$configlog"

#Prompt user for password unless updating
apfile="/home/ARPiE/Config/APPasswd" #Password Saved to text file for future updates :/
if [[ ! -e $update ]]; then
	echo "Please provide a WiFi AP Password:"
	answer=
	password=answer
	
	touch $apfile
	echo $password >> "$apfile"
else
	password=cat $apfile
fi

#Write hostapd config file with devicename for wireless
echo "Date:"$( date )" - Starting Hostapd.conf Configuration" >> "$configlog"
echo 'Configuring WiFi AP for '$devicename'.'
file="/home/pi/ARPiE/Config/hostapd.conf"
tofile="/etc/hostapd/hostapd.conf"
touch $file
echo 'interface=wlan0' >> "$file"
echo 'driver=nl80211' >> "$file"
echo 'ssid='$devicename >> "$file"
echo 'hw_mode=g' >> "$file"
echo 'channel=6' >> "$file"
echo 'ieee80211n=1' >> "$file"
echo 'wmm_enabled=1' >> "$file"
echo 'ht_capab=[HT40][SHORT-GI-20][DSSS_CCK-40]' >> "$file"
echo 'macaddr_acl=0' >> "$file"
echo 'auth_algs=1' >> "$file"
echo 'ignore_broadcast_ssid=0' >> "$file"
echo 'wpa=2' >> "$file"
echo 'wpa_key_mgmt=WPA-PSK' >> "$file"
echo 'wpa_passphrase='$password >> "$file"
echo 'rsn_pairwise=CCMP' >> "$file"
sudo cp $file $tofile
echo "Date:"$( date )" - Hostapd.conf Configuration Complete" >> "$configlog"

#hostapd setup to enable conf read
echo "Date:"$( date )" - Starting Hostapd Configuration" >> "$configlog"
file="/home/pi/ARPiE/Config/hostapd"
tofile="/etc/default/hostapd"
touch $file
echo '# Defaults for hostapd initscript' >> "$file"
echo '#' >> "$file"
echo '# See /usr/share/doc/hostapd/README.Debian for information about alternative' >> "$file"
echo '# methods of managing hostapd.' >> "$file"
echo '#' >> "$file"
echo '# Uncomment and set DAEMON_CONF to the absolute path of a hostapd configuration' >> "$file"
echo '# file and hostapd will be started during system boot. An example configuration' >> "$file"
echo '# file can be found at /usr/share/doc/hostapd/examples/hostapd.conf.gz' >> "$file"
echo '#' >> "$file"
echo 'DAEMON_CONF="/etc/hostapd/hostapd.conf"' >> "$file"
echo '' >> "$file"
echo '# Additional daemon options to be appended to hostapd command:-' >> "$file"
echo '# 	-d   show more debug messages (-dd for even more)' >> "$file"
echo '# 	-K   include key data in debug messages' >> "$file"
echo '# 	-t   include timestamps in some debug messages' >> "$file"
echo '#' >> "$file"
echo '# Note that -B (daemon mode) and -P (pidfile) options are automatically' >> "$file"
echo '# configured by the init.d script and must not be added to DAEMON_OPTS.' >> "$file"
echo '#' >> "$file"
echo '#DAEMON_OPTS=""' >> "$file"
sudo cp $file $tofile
echo "Date:"$( date )" - Hostapd Configuration Complete" >> "$configlog"

#Set Active Cores
echo "Date:"$( date )" - Starting Cmdline.txt Configuration" >> "$configlog"
echo 'Setting Active cores to '$corecount'.'
file="/home/pi/ARPiE/Config/cmdline.txt"
tofile="/boot/cmdline.txt"
echo 'dwx_otg.lpm_enable=0 console=serial0,115200 console=ttyl root=/dev/mmcblk0p2 rootfstype=ext4 elevator=deadline fsck.repair=yes rootwait maxcpus='$corecount >> "$file"
sudo cp $file $tofile
echo "Date:"$( date )" - Cmdline.txt Configuration Complete" >> "$configlog"

#Set WVDIAL Config Settings
echo "Date:"$( date )" - Starting Wvdial.conf Configuration" >> "$configlog"
echo 'Setting 3G Modem up for '$carrier'.'
file="/home/pi/ARPiE/Config/wvdial.conf"
tofile="/etc/wvdial.conf"
echo '[Dialer Defaults]' >> "$file"
echo 'Init1 = ATZ' >> "$file"
echo 'Init2 = ATQ0' >> "$file"
#Set APN Based On Carrier selection
if [[ $carrier = "ATT" ]]; then
	echo "Date:"$( date )" - Choosing AT&T Carrier" >> "$configlog"
	echo 'Init3 = AT+CGDCONT=1,"IP","wyless.com.attz",,0,0' >> "$file"
elif [[ $carrier = "AATT" ]]; then
	echo "Date:"$( date )" - Choosing Aeris AT&T Carrier" >> "$configlog"
	echo 'Init3 = AT+CGDCONT=1,"IP","iotst.aer.net",,0,0' >> "$file" 
elif [[ $carrier = "A" ]]; then
	echo "Date:"$( date )" - Chosing Aeris Carrier" >> "$configlog"
	echo 'Init3 = AT+CGDCONT=1,"IP","aerst.aerisapn.eu",,0,0' >> "$file"
elif [[ $carrier = "IO" ]]; then
	echo "Date:"$( date )" - Choosing Hologram Carrier" >> "$configlog"
	echo 'Init3 = AT+CGDCONT=1,"IP","apn.konekt.io",,0,0' >> "$file"
fi
echo 'Stupid Mode = 1' >> "$file"
echo 'Dial Attempts = 0' >> "$file"
echo 'Auto Reconnect = yes' >> "$file"
echo 'Modem Type = Analog Modem' >> "$file"
echo 'Baud = 7200000' >> "$file"
echo 'New PPPD = yes' >> "$file"
echo 'Modem = /dev/ttyUSB0' >> "$file"
if [[ $carrier = "IO" ]]; then #Hologram.io has a different phone dial
	echo 'Phone = *99***1#' >> "$file"
else
	echo 'Phone = *99#' >> "$file"
fi
echo 'ISDN = 0' >> "$file"
echo 'Password = { }' >> "$file"
echo 'Username = { }' >> "$file"
sudo cp $file $tofile
sleep 3
clear
echo "Date:"$( date )" - Wvdial.conf Configuration Complete" >> "$configlog"

#Crontab Configuration
echo "Date:"$( date )" - Starting Crontab Configuration" >> "$configlog"
file="/home/pi/ARPiE/Config/crontab"
tofile="/home/pi/ARPiE/Config/sudo_crontab"
crontab -l >> "$file"
echo '@reboot sleep 60 && /home/pi/ARPiE/arpie' >> "$file"
echo '0 */6 * * * /home/pi/ARPiE/updater' >> "$file"
sudo crontab -l >> "$tofile"
echo '@reboot sleep 60 && /home/pi/ARPiE/sudo_arpie' >> "$tofile"
echo '@reboot sleep 120 && /home/pi/ARPiE/ppp0_check' >> "$tofile"
echo '@reboot sleep 180 && /home/pi/ARPiE/eth0_check' >> "$tofile"
echo '@reboot sleep 600 && /home/pi/ARPiE/power_monitor' >> "$tofile"
echo '0 */1 * * * /home/pi/ARPiE/helper' >> "$tofile"
echo '0 */6 * * * /home/pi/ARPiE/updater' >> "$tofile"
crontab -u pi "$file"
sudo crontab "$tofile"
echo "Date:"$( date )" - Crontab Configuration Complete" >> "$configlog"

#Interfaces Configuration
echo "Date:"$( date )" - Starting Interfaces Configuration" >> "$configlog"
file="/home/pi/ARPiE/Config/interfaces.help"
tofile="/etc/network/interfaces"
oldfile="/home/pi/ARPiE/Config/interfaces.helper"
echo 'source-directory /etc/network/interfaces.d' >> "$file"
echo '' >> "$file"
echo 'auto lo' >> "$file"
echo 'iface lo inet loopback' >> "$file"
echo '' >> "$file"
echo 'allow hotplug eth0' >> "$file"
echo 'iface eth0 inet static' >> "$file"
echo '	address 10.100.100.1' >> "$file"
echo '	netmask 255.255.255.0' >> "$file"
echo '	network 10.100.100.0' >> "$file"
echo '	broadcast 10.100.100.255' >> "$file"
echo '' >> "$file"
echo 'allow-hotplug wlan0' >> "$file"
echo 'iface wlan0 inet static' >> "$file"
echo '	address 10.100.101.1' >> "$file"
echo '	netmask 255.255.255.0' >> "$file"
echo '	network 10.100.101.0' >> "$file"
echo '	broadcast 10.100.101.255' >> "$file"
echo '	#wpa-conf /etc/wpa_supplicant/wpa_supplicant.conf' >> "$file"
echo '' >> "$file"
echo 'iface ppp0 inet wvdial' >> "$file"
echo '	post-up echo "3G (ppp0) is online"' >> "$file"
echo '' >> "$file"
echo 'allow-hotplug wlan1' >> "$file"
echo 'iface wlan1 inet manual' >> "$file"
echo '	wpa-conf /etc/wpa_supplicant/wpa_supplicant.conf' >> "$file"
sudo cp $file $tofile
echo "Date:"$( date )" - Interfaces Configuration Complete" >> "$configlog"
#Need to modify this before production release for customized ip range/eth0 config

#dnsmasq.conf Configuration
echo "Date:"$( date )" - Starting Dnsmasq.conf Configuration" >> "$configlog"
file="/home/pi/ARPiE/Config/dnsmasq.conf"
tofile="/etc/dnsmasq.conf"
touch $file
echo 'interface=wlan0' >> "$file"
echo 'listen-address=10.100.101.1' >> "$file"
echo 'bind-interfaces' >> "$file"
echo 'server=8.8.8.8' >> "$file"
echo 'domain-needed' >> "$file"
echo 'bogus-priv' >> "$file"
echo 'dhcp-range=10.100.101.10,10.100.101.50,12h' >> "$file"
sudo cp $file $tofile
echo "Date:"$( date )" - Dnsmasq.conf Configuration Complete" >> "$configlog"

#dhcpcd.conf Configuration
echo "Date:"$( date )" - Starting Dhcpcd.conf Configuration" >> "$configlog"
file="/home/pi/ARPiE/Config/dhcpcd.conf.help"
tofile="/etc/dhcpcd.conf"
oldfile="/home/pi/ARPiE/Config/dhcpcd.conf.helper"
if [[ ! -e $oldfile ]]; then
	cp $tofile $oldfile
fi
cp $tofile $file
echo '' >> "$file"
echo '#Wireless Restrict for AP' >> "$file"
echo 'denyinterfaces wlan0' >> "$file"
sudo cp $oldfile $tofile
echo "Date:"$( date )" - Dhcpcd.conf Configuration Complete" >> "$configlog"

#Reboot prompt
file="/home/pi/ARPiE/Logs/update.log"
echo 'Device Name:'$devicename' has been configured for '$corecount' active core(s) and to connect to the '$carrier' network'
echo 'Reboot Now (Y/N)?'
echo "Date:"$( date )" - Configuration Completed" >> "$configlog"
#Update Cleanup / Reboot Option
if [[ ! -e $update ]]; then
	answer=
	while [[ ! $answer ]]; do
		read -r -n 1 -s answer
		if [[ $answer = [Yy] ]]; then
			sudo shutdown now -r
			exit 0 #Just for the lulz =P
		elif [[ $answer = [Nn] ]]; then
			exit 0
		fi
	done
else
	echo "Date:"$( date )" Config File Completed on Device Name:"$devicename" With Cores:"$corecount" Carrier Selection:"$carrier >> "$file"
	exit 0
fi
exit 0
