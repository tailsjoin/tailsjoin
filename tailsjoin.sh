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
echo -e "\n\nTHIS SCRIPT WILL INSTALL JOINMARKET AND ITS DEPENDENCIES FOR A MINIMAL TAILS OS WITH NO LOCAL BLOCKCHAIN STORAGE, USING BLOCKR.IO FOR BLOCKCHAIN LOOKUPS (ALWAYS OVER TOR).\n\n"
# Update
echo -e "ENTER PASSWORD AT PROMPT TO UPDATE SOURCES.\n"
sudo apt-get update
# Install dependencies available with apt-get
clear
echo -e "\n\nENTER PASSWORD AT PROMPT TO INSTALL THE FOLLOWING DEPENDENCIES:\n"
echo -e "gcc, libc6-dev, make\n"
sudo apt-get install -y gcc libc6-dev make
# Fetch libsodium and sig, import key, and verify.
clear
echo -e "\n\nPRESS ENTER TO GET SIGNING KEYS AND VERIFY LIBSODIUM SOURCE FROM:\n"
read -p "http://download.libsodium.org/libsodium/releases/libsodium-1.0.3.tar.gz"
gpg --recv-keys 54A2B8892CC3D6A597B92B6C210627AABA709FE1
echo "54A2B8892CC3D6A597B92B6C210627AABA709FE1:6" | gpg --import-ownertrust -
curl -x socks5://127.0.0.1:9050 -# -L -O http://download.libsodium.org/libsodium/releases/libsodium-1.0.3.tar.gz -O http://download.libsodium.org/libsodium/releases/libsodium-1.0.3.tar.gz.sig
gpg --verify libsodium-1.0.3.tar.gz.sig libsodium-1.0.3.tar.gz
echo -e "\n\nPLEASE REVIEW SIGNATURE.\n"
read -p "GOOD SIG? (y/n) " x
while [[ "$x" = "n" || "$x" = "N" ]]; do
  clear
  echo -e "\n\n"
  read -p "PRESS ENTER TO DELETE FILES AND GET AGAIN."
  srm -drv libsodium*
  curl -x socks5://127.0.0.1:9050 -# -L -O http://download.libsodium.org/libsodium/releases/libsodium-1.0.3.tar.gz -O http://download.libsodium.org/libsodium/releases/libsodium-1.0.3.tar.gz.sig
  gpg --verify libsodium-1.0.3.tar.gz.sig libsodium-1.0.3.tar.gz
  echo -e "\n\nPLEASE REVIEW THE SIG TO MAKE SURE IT IS GOOD.\n"
  read -p "GOOD SIG? (y/n) " x
done
# Build libsodium, install, and delete tar files
tar xf libsodium-1.0.3.tar.gz
rm -rf libsodium-1.0.3.tar.gz*
( cd libsodium-1.0.3/ && ./configure )
( cd libsodium-1.0.3/ && make )
clear
echo -e "\n\nLIBSODIUM SUCCESSFULLY BULIT. ENTER PASSWORD TO INSTALL.\n"
( cd libsodium-1.0.3/ && sudo make install )
rm -rf libsodium-1.0.3/
# Clone into joinmarket
clear
# This code for allowing amnesia access to the python modules lifted from the Axis-Mundi README.TAILS (https://github.com/six-pack/Axis-Mundi/blob/master/README.TAILS)
echo -e "\n\nENTER PASSWORD TO ALLOW USER amnesia TO USE PYTHON MODULES WITH COMMAND:\n"
echo -e "sudo chmod -R o+r,o+X /usr/local/lib/python2.7/dist-packages\n"
sudo chmod -R o+r,o+X /usr/local/lib/python2.7/dist-packages
clear
echo -e "\n\nPRESS ENTER TO CLONE INTO JOINMARKET VIA:\n"
read -p "https://github.com/chris-belcher/joinmarket"
git clone https://github.com/chris-belcher/joinmarket ../joinmarket
# Set config for tor and blockr. Tails users should consider using external media with a stored blockchain for added privacy and the tailsjoin-fullnode.sh script.
echo -e "[BLOCKCHAIN]\nblockchain_source = blockr\n#options: blockr, bitcoin-rpc, json-rpc, regtest\n#for instructions on bitcoin-rpc read https://github.com/chris-belcher/joinmarket/wiki/Running-JoinMarket-with-Bitcoin-Core-full-node \nnetwork = mainnet\nrpc_host = localhost\nrpc_port = 8332\nrpc_user = bitcoin\nrpc_password = password\n\n[MESSAGING]\n#host = irc.cyberguerrilla.org\nchannel = joinmarket-pit\nport = 6697\nusessl = true\nsocks5 = true\nsocks5_host = 127.0.0.1\nsocks5_port = 9050\n#for tor\nhost = a2jutl5hpza43yog.onion" > ../joinmarket/joinmarket.cfg
clear
echo -e "\n\nJOINMARKET INSTALLED, AND CONFIG SET TO USE TOR!"
echo -e "\n\nYOU CAN FIND THE FOLDER HERE:"
echo $PWD | sed 's|tailsjoin|joinmarket|'
echo -e "\nHERE IS A DETAILED BEGINNERS GUIDE:"
echo "https://github.com/tailsjoin/tailsjoin/wiki/Detailed-Minimal-Setup-Guide"
echo -e "\nHERE IS A HIDDEN SERVICE ORDERBOOK WATCHER:"
echo "http://ruc47yiosooolrzw.onion:62601/"
echo -e "\nHERE IS THE JOINMARKET OFFICIAL GITHUB:"
echo -e "https://github.com/chris-belcher/joinmarket\n\n"
read -p "PRESS ENTER TO EXIT. "
exit 0