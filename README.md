# arch-linux-base
## Arch Linux base instalation

### First steps
- Boot ISO image
- Set loadkeys if necessary
- Download repositories and install git -> `pacman -Sy git`
- Clone repository -> `git clone https://github.com/perekuera/arch-linux-base.git`
- Move to scripts folder -> `cd ./arh-linux-base/scripts`
- Edit install.conf file -> `nano ./install.conf`
- Execute script -> `sh 00-install-base.sh`

### Wifi conectivity
You need internet connection at this moment. Use `wifi-menu` to configure it if necessary.


##### Some scripts in 'extra' folder from [Erik Dubois](https://erikdubois.be){:target="_blank"} - [GitHub](https://github.com/erikdubois){:target="_blank"}
