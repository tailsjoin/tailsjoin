#!/bin/bash
set -e
clear
echo -e "\n\nYOU ARE CURRENTLY IN THE FOLDER $(echo "$PWD")"
read -p "IS THIS WHERE YOU WANT TO DOWNLOAD BITCOIN? (y/n) " x
if [[ "$x" = "n" || "$x" = "N" ]]; then
  clear
  echo -e "\n\nPLEASE MOVE THE SCRIPT tailsjoincore.sh TO THE FOLDER WHERE"
  echo -e "BITCOIN WILL GO AND RUN AGAIN.\n\n"
  read -p "PRESS ENTER TO EXIT. "
  exit 0
fi
clear
echo -e "\n\nPRESS ENTER TO GET BITCOIN CORE AND CHECKSUMS FROM:\n"
echo "https://bitcoin.org/bin/bitcoin-core-0.11.0/bitcoin-0.11.0-linux32.tar.gz"
echo "https://bitcoin.org/bin/bitcoin-core-0.11.0/SHA256SUMS.asc "; read
wget https://bitcoin.org/bin/bitcoin-core-0.11.0/bitcoin-0.11.0-linux32.tar.gz https://bitcoin.org/bin/bitcoin-core-0.11.0/SHA256SUMS.asc
clear
echo -e "\n\nIMPORTING KEY: 0x90C8019E36C2E964 TO CHECK SIG."
gpg --recv-keys 01EA5486DE18A882D4C2684590C8019E36C2E964
gpg --verify SHA256SUMS.asc
echo -e "\n\nPLEASE REVIEW THE SIG TO MAKE SURE IT IS GOOD.\n"
read -p "GOOD SIG? (y/n) " x
while [[ "$x" = "n" || "$x" = "N" ]]; do
  clear
  echo -e "\n\n"; read -p "PRESS ENTER TO DELETE FILES AND GET AGAIN."
  srm -drv SHA256SUMS.asc
  wget https://bitcoin.org/bin/bitcoin-core-0.11.0/SHA256SUMS.asc
  gpg --verify SHA256SUMS.asc
  echo -e "\n\nPLEASE REVIEW THE SIG TO MAKE SURE IT IS GOOD.\n"
  read -p "GOOD SIG? (y/n) " x
done
clear
echo -e "\n\nCHECKING THE SHA256 SUM OF DOWNLOADED BITCOIN CLIENT."
sha=$(grep linux32.tar.gz SHA256SUMS.asc | cut -b -64)
echo ""; echo ""$sha"  bitcoin-0.11.0-linux32.tar.gz" | shasum -c
echo""; read -p 'DID THAT SHOW: "bitcoin-0.11.0-linux32.tar.gz: OK" ? (y/n) ' x
while [[ "$x" = "n" || "$x" = "N" ]]; do
  clear
  echo -e "\n\n"; read -p "PRESS ENTER TO DELETE FILES AND GET AGAIN."
  srm -drv bitcoin-0.11.0-linux32.tar.gz
  wget https://bitcoin.org/bin/bitcoin-core-0.11.0/bitcoin-0.11.0-linux32.tar.gz
  echo ""; read -p "PRESS ENTER TO CHECK THE SHA256 SUM OF DOWNLOADED BITCOIN CLIENT."
  sha=$(grep linux32.tar.gz SHA256SUMS.asc | cut -b -64)
  echo ""; echo ""$sha"  bitcoin-0.11.0-linux32.tar.gz" | shasum -c
  echo""; read -p 'DID THAT SHOW: "bitcoin-0.11.0-linux32.tar.gz: OK" ? (y/n) ' x
done
clear
echo -e "\n\nPRESS ENTER TO EXTRACT BITCOIN AND DELETE USELESS FILES."; read
tar -xvf bitcoin-0.11.0-linux32.tar.gz
srm -dlrv bitcoin-0.11.0-linux32.tar.gz SHA256SUMS.asc
clear
echo -e "\n\nPRESS ENTER TO PUT THESE SETTINGS IN YOUR BITCOIN.CONF:\n"
bitconf=$(echo -e "daemon=1\nrpcuser=$(pwgen -ncsB 35 1)\nrpcpassword=$(pwgen -ncsB 75 1)\nproxy=127.0.0.1:9050\nproxyrandomize=1\nserver=1\ntxindex=1\n# JoinMarket Settings\nwalletnotify=curl -sI --connect-timeout 1 http://localhost:62602/walletnotify?%s\nalertnotify=curl -sI --connect-timeout 1 http://localhost:62062/alertnotify?%s\n# User to input blockchain path\ndatadir=")
echo "$bitconf"
read
if [ -e "bitcoin-0.11.0/bin/bitcoin.conf" ]; then
  clear
  echo ""; read -p 'FILE "bitcoin.conf" EXISTS. OVERWRITE? (y/n) ' ow
  if  [[ "$ow" = "n" || "$ow" = "N" ]]; then
    echo ""; read -p "PRESS ENTER TO EXIT SCRIPT"
    exit 0
  fi
fi
echo "$bitconf" > bitcoin-0.11.0/bin/bitcoin.conf
clear
echo -e "\nYOU WILL NEED TO ENTER YOUR DATA DIRECTORY IN THE CONFIG."
echo -e "CONFIG FILE IS LOCATED AT: bitcoin-0.11.0/bin/bitcoin.conf"
# This code was lifted from Axis-Mundi README.TAILS (https://github.com/six-pack/Axis-Mundi/blob/master/README.TAILS)
echo -e "\n\nENTER TO ALLOW CALLS TO LOCALHOST BY ADJUSTING IPTABLES USING THIS COMMAND:\n"
echo -e "sudo iptables -I OUTPUT 2 -p tcp -s 127.0.0.1 -d 127.0.0.1 -m owner --uid-owner amnesia -j ACCEPT\n"
sudo iptables -I OUTPUT 2 -p tcp -s 127.0.0.1 -d 127.0.0.1 -m owner --uid-owner amnesia -j ACCEPT
clear
echo -e "\n\nNOW WE WILL INSTALL JOINMARKET AND ITS DEPENDENCIES."
echo -e "\nENTER PASSWORD AT PROMPT TO UPDATE SOURCES.\n"
sudo apt-get update
clear
echo -e "\n\nENTER PASSWORD AT PROMPT TO INSTALL THE FOLLOWING DEPENDENCIES:\n"
echo -e "gcc, libc6-dev, make, python-dev, python-pip\n"
sudo apt-get install -y gcc libc6-dev make python-dev python-pip
clear
echo -e "\n\nPRESS ENTER TO GET LIBSODIUM AND VERIFY SOURCE FROM:\n"
echo -e "http://download.libsodium.org/libsodium/releases/libsodium-1.0.3.tar.gz\n"; read
wget http://download.libsodium.org/libsodium/releases/libsodium-1.0.3.tar.gz http://download.libsodium.org/libsodium/releases/libsodium-1.0.3.tar.gz.sig
gpg --recv-keys 54A2B8892CC3D6A597B92B6C210627AABA709FE1
echo "54A2B8892CC3D6A597B92B6C210627AABA709FE1:6" | gpg --import-ownertrust -
gpg --verify libsodium-1.0.3.tar.gz.sig libsodium-1.0.3.tar.gz
echo -e "\n\nPLEASE REVIEW THE SIG TO MAKE SURE IT IS GOOD.\n"
read -p "GOOD SIG? (y/n) " x
while [[ "$x" = "n" || "$x" = "N" ]]; do
  clear
  echo -e "\n\n"; read -p "PRESS ENTER TO DELETE FILES AND GET AGAIN."
  srm -drv libsodium*
  wget http://download.libsodium.org/libsodium/releases/libsodium-1.0.3.tar.gz http://download.libsodium.org/libsodium/releases/libsodium-1.0.3.tar.gz.sig
  gpg --verify libsodium-1.0.3.tar.gz.sig libsodium-1.0.3.tar.gz
  echo -e "\n\nPLEASE REVIEW THE SIG TO MAKE SURE IT IS GOOD.\n"
  read -p "GOOD SIG? (y/n) " x
done
tar xf libsodium-1.0.3.tar.gz
rm -rf libsodium-1.0.3.tar.gz*
( cd libsodium-1.0.3/ && ./configure )
( cd libsodium-1.0.3/ && make )
clear
echo -e "\nENTER PASSWORD AT PROMPT TO INSTALL LIBSODIUM AND DELETE USELESS FILES.\n"
( cd libsodium-1.0.3/ && sudo make install )
rm -rf libsodium-1.0.3/
clear
echo -e "\nENTER PASSWORD AT PROMPT TO UPGRADE NUMPY TO VERSION 1.9.2\n"
sudo torify pip install numpy --upgrade
clear
# This code for allowing amnesia access to the python modules lifted from the Axis-Mundi README.TAILS (https://github.com/six-pack/Axis-Mundi/blob/master/README.TAILS)
echo -e "\n\nENTER PASSWORD TO ALLOW USER amnesia TO USE PYTHON MODULES WITH COMMAND:\n"
echo -e "sudo chmod -R o+r,o+X /usr/local/lib/python2.7/dist-packages\n"
sudo chmod -R o+r,o+X /usr/local/lib/python2.7/dist-packages
clear
echo -e "\n\nPRESS ENTER TO CLONE INTO JOINMARKET VIA:\n"
echo -e "https://github.com/chris-belcher/joinmarket\n"; read
git clone https://github.com/chris-belcher/joinmarket joinmarket
echo -e "[BLOCKCHAIN]\nblockchain_source = json-rpc\n#options: blockr, json-rpc, regtest\n#before using json-rpc read https://github.com/chris-belcher/joinmarket/wiki/Running-JoinMarket-with-Bitcoin-Core-full-node\nnetwork = mainnet\nbitcoin_cli_cmd = $PWD/bitcoin-0.11.0/bin/bitcoin-cli -conf=$PWD/bitcoin-0.11.0/bin/bitcoin.conf\n\n[MESSAGING]\nchannel = joinmarket-pit\nusessl = true\n#for tor\nsocks5 = true\nsocks5_host = 127.0.0.1\nsocks5_port = 9050\nhost = a2jutl5hpza43yog.onion\nport = 6697\n" > joinmarket/joinmarket.cfg
clear
echo -e "\n\nJOINMARKET CLONED, AND CONFIG SET TO USE TOR AND BITCOIN RPC!\n"
read -p "PRESS ENTER FOR SOME FINAL NOTES. "
clear
echo -e "\n\nPLEASE GO HERE TO GET DETAILED INFO ON HOW TO OPERATE FROM THE CREATOR:"
echo "https://github.com/chris-belcher/joinmarket/wiki"
echo -e "\nYOU CAN RUN BITCOIN BY ENTERING THE FOLDER:"
echo " $PWD/bitcoin-0.11.0/bin"
echo "AND USE THIS COMMAND:"
echo "./bitcoind -conf=$PWD/bitcoin-0.11.0/bin/bitcoin.conf"
echo -e "\nYOU MUST NOW ENTER YOUR DATA DIR IN THE BITCOIN CONFIG FILE."
echo -e "EXAMPLE ENTRY:\ndatadir=/media/mounted_device/.bitcoin/\n\n"
read -p "PRESS ENTER TO LEAVE SCRIPT. "
exit 0
