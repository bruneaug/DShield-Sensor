# DShield Sensor Files
This section is storing files that can be used on the DShield sensor to automate some tasks.

````
git clone https://github.com/bruneaug/DShield-Sensor.git
mkdir scripts 
cp DShield-Sensor/sensor_scripts/* ~/scripts/
chmod 754 ~/scripts/*.sh
````
This file in Suricata directory is used to enable logrotate for Suricata.
It is copied to /etc/logrotate.d
```
sudo cp DShield-Sensor/Suricata/suricata /etc/logrotate.d
```
