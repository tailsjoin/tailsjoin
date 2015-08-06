#!/bin/bash
set -e
clear
if [[ $(id -u) = "0" ]]; then
  echo -e "\n\nYOU SHOULD NOT RUN THIS SCRIPT AS ROOT!"
  echo -e "YOU WILL BE PROMPTED FOR THE ADMIN PASS WHEN NEEDED.\n\n"
  read -p "PRESS ENTER TO EXIT SCRIPT"
  exit 0
fi
if  [[ $(echo "$PWD" | grep -c Persistent) = "0" && -e /home/amnesia/Persistent ]]; then
  echo -e "\n\nIT SEEMS YOU HAVE PERSISTENCE ENABLED, BUT YOU'RE IN THE FOLDER:"
  echo "$PWD"
  echo -e "IT MAY BE WISE TO QUIT NOW AND MOVE THIS FOLDER TO PERSISTENCE.\n\n"
  read -p "QUIT NOW? (y/n) " q
  if  [[ "$q" = "y" || "$q" = "Y" ]]; then
    exit 0
  else
    clear
  fi
fi
echo -e "\n\nTHIS SCRIPT WILL INSTALL JOINMARKET AND ITS DEPENDENCIES FOR TAILS OS.\n\n"
# Update
echo -e "ENTER PASSWORD AT PROMPT TO UPDATE SOURCES.\n"
sudo apt-get update
# Install dependencies available with apt-get
clear
echo -e "\n\nENTER PASSWORD AT PROMPT TO INSTALL THE FOLLOWING DEPENDENCIES:\n"
echo -e "gcc, libc6-dev, make, python-dev, python-pip\n"
sudo apt-get install -y gcc libc6-dev make python-dev python-pip
# Fetch libsodium and sig, import key, and verify.
clear
echo -e "\n\nPRESS ENTER TO GET SIGNING KEYS AND VERIFY LIBSODIUM SOURCE FROM:\n"
read -p "http://download.libsodium.org/libsodium/releases/libsodium-1.0.3.tar.gz"
gpg --recv-keys 54A2B8892CC3D6A597B92B6C210627AABA709FE1
echo "54A2B8892CC3D6A597B92B6C210627AABA709FE1:6" | gpg --import-ownertrust -
wget http://download.libsodium.org/libsodium/releases/libsodium-1.0.3.tar.gz http://download.libsodium.org/libsodium/releases/libsodium-1.0.3.tar.gz.sig
gpg --verify libsodium-1.0.3.tar.gz.sig libsodium-1.0.3.tar.gz
echo -e "\n\nPLEASE REVIEW SIGNATURE.\n"
read -p "GOOD SIG? (y/n) " x
while [[ "$x" = "n" || "$x" = "N" ]]; do
  clear
  echo -e "\n\n"
  read -p "PRESS ENTER TO DELETE FILES AND GET AGAIN."
  srm -drv libsodium*
  wget http://download.libsodium.org/libsodium/releases/libsodium-1.0.3.tar.gz http://download.libsodium.org/libsodium/releases/libsodium-1.0.3.tar.gz.sig
  gpg --verify libsodium-1.0.3.tar.gz.sig libsodium-1.0.3.tar.gz
  echo -e "\n\nPLEASE REVIEW THE SIG TO MAKE SURE IT IS GOOD.\n"
  read -p "GOOD SIG? (y/n) " x
done
# Build libsodium, install, and delete tar files
tar xf libsodium-1.0.3.tar.gz
srm -drv libsodium-1.0.3.tar.gz*
( cd libsodium-1.0.3/ && ./configure )
( cd libsodium-1.0.3/ && make )
clear
echo -e "\n\nLIBSODIUM SUCCESSFULLY BULIT. ENTER PASSWORD TO INSTALL.\n"
( cd libsodium-1.0.3/ && sudo make install )
rm -rf libsodium-1.0.3/
# Use pip to upgrade numpy
clear
echo -e "\n\nENTER PASSWORD AT PROMPT TO UPGRADE NUMPY TO VERSION 1.9.2\n"
sudo torify pip install numpy --upgrade
# Clone into joinmarket
clear
echo -e "\n\nPRESS ENTER TO CLONE INTO JOINMARKET VIA:\n"
read -p "https://github.com/chris-belcher/joinmarket"
git clone https://github.com/chris-belcher/joinmarket ../joinmarket
# Set config for tor and blockr. Tails users should consider using an external hdd with bitcoin core.
echo -e "[BLOCKCHAIN]\nblockchain_source = blockr\n#options: blockr, json-rpc, regtest\n#before using json-rpc read https://github.com/chris-belcher/joinmarket/wiki/Running-JoinMarket-with-Bitcoin-Core-full-node\nnetwork = mainnet\nbitcoin_cli_cmd = bitcoin-cli\n\n[MESSAGING]\n#for clearnet\n#host = irc.cyberguerrilla.info\nchannel = joinmarket-pit\nusessl = true\n#for tor\nsocks5 = false\nsocks5_host = 127.0.0.1\nsocks5_port = 9050\n#host = 6dvj6v5imhny3anf.onion\nhost = a2jutl5hpza43yog.onion\n#socks5 = true\nport = 6697\n" > ../joinmarket/joinmarket.cfg
clear
echo -e "\n\nJOINMARKET INSTALLED, AND CONFIG SET TO USE TOR."
echo -e "YOU CAN FIND THE FOLDER HERE:"
echo $PWD | sed 's|\/tailsjoin||'
echo -e "\n\nPLEASE GO HERE TO GET DETAILED INFO ON HOW TO OPERATE:"
echo -e "https://github.com/chris-belcher/joinmarket/wiki\n\n"
read -p "PRESS ENTER TO EXIT."
exit 0
