#!/bin/bash
set -e
clear


# Check for root.
if [[ $(id -u) = "0" ]]; then
  echo "
YOU SHOULD NOT RUN THIS SCRIPT AS ROOT!
YOU WILL BE PROMPTED FOR THE ADMIN PASS WHEN NEEDED.
"
  read -p "PRESS ENTER TO EXIT SCRIPT, AND RUN AGAIN AS amnesia. "
  exit 0
fi


# Make sure user has chosen the correct script.
echo "
          THIS SCRIPT WILL INSTALL JOINMARKET AND ITS DEPENDENCIES ON
          A MINIMAL TAILS OS WITHOUT A LOCAL BLOCKCHAIN. YOU WILL BE
       USING THE BLOCKR.IO API FOR BLOCKCHAIN LOOKUPS (ALWAYS OVER TOR).
"
read -p "PRESS ENTER TO CONTINUE. "
clear


# Check for persistence.
if  [[ $(pwd | grep -c Persistent) = "0" && -e /home/amnesia/Persistent ]]; then
  echo "
IT SEEMS YOU HAVE PERSISTENCE ENABLED, BUT YOU ARE IN THE FOLDER:
"$PWD"
IF YOU MOVE THE tailsjoin/ FOLDER TO /home/amnesia/Persistent/
YOUR INSTALL WILL SURVIVE REBOOTS, OTHERWISE IT WILL NOT.
"
  read -p "QUIT THE SCRIPT NOW TO MOVE? (y/n) " q
  if  [[ "$q" = "y" || "$q" = "Y" ]]; then
    exit 0
  else
    clear
  fi
fi


# Update apt-get sources.
echo "
ENTER PASSWORD TO UPDATE SOURCES.
"
sudo apt-get update
clear


# Install dependencies for building libsodium.
echo "
ENTER PASSWORD TO INSTALL: 'gcc', 'libc6-dev', and 'make'
(NEEDED TO BUILD LIBSODIUM CRYPTO LIBRARY)
"
sudo apt-get install -y gcc libc6-dev make
clear


# Clone JoinMarket.
git clone https://github.com/chris-belcher/joinmarket ../joinmarket
clear


# Get libsodium, sig, and import key.
echo "
DOWNLOADING LIBSODIUM SOURCE AND SIGNING KEY...
"
gpg --recv-keys 54A2B8892CC3D6A597B92B6C210627AABA709FE1
echo "54A2B8892CC3D6A597B92B6C210627AABA709FE1:6" | gpg --import-ownertrust -
curl -x socks5://127.0.0.1:9050 -# -L -O http://download.libsodium.org/libsodium/releases/libsodium-1.0.3.tar.gz -O http://download.libsodium.org/libsodium/releases/libsodium-1.0.3.tar.gz.sig
clear


# Verify download.
echo "
VERIFYING THE DOWNLOAD...
"
gpg --verify libsodium-1.0.3.tar.gz.sig libsodium-1.0.3.tar.gz
echo "
PLEASE REVIEW THE TEXT ABOVE.
IT WILL EITHER SAY GOOD SIG OR BAD SIG.
"
read -p "IS IT A GOOD SIG? (y/n) " x
while [[ "$x" = "n" || "$x" = "N" ]]; do
  clear
  echo "
SECURELY DELETING FILES AND DOWNLOADING AGAIN...
"
  srm -drv libsodium*
  curl -x socks5://127.0.0.1:9050 -# -L -O http://download.libsodium.org/libsodium/releases/libsodium-1.0.3.tar.gz -O http://download.libsodium.org/libsodium/releases/libsodium-1.0.3.tar.gz.sig
  gpg --verify libsodium-1.0.3.tar.gz.sig libsodium-1.0.3.tar.gz
  echo "
PLEASE REVIEW THE TEXT ABOVE.
IT WILL EITHER SAY GOOD SIG OR BAD SIG.
"
  read -p "IS IT A GOOD SIG? (y/n) " x
done
clear


# Build and install libsodium.
tar xf libsodium-1.0.3.tar.gz
rm -rf libsodium-1.0.3.tar.gz*

if [[ $(pwd | grep -c Persistent) = "1" ]]; then
  echo "
BUILDING AND INSTALLING LIBSODIUM TO SURVIVE REBOOTS...
"
  mkdir ../joinmarket/libsodium
  ( cd libsodium-1.0.3/ && ./configure --prefix=$(pwd) && make && make install )
  mv libsodium-1.0.3/lib/libsodium.* ../joinmarket/libsodium/
  sed -i "s|\/usr\/local\/lib|$(pwd | sed 's|tailsjoin|joinmarket\/libsodium|')|" ../joinmarket/lib/libnacl/__init__.py
else
  echo "
BUILDING, LIBSODIUM...
"
  ( cd libsodium-1.0.3/ && ./configure && make )
  echo "
LIBSODIUM SUCCESSFULLY BULIT. ENTER PASSWORD TO INSTALL.
"
  ( cd libsodium-1.0.3/ && sudo make install )
fi
rm -rf libsodium-1.0.3/
clear


# Set JoinMarket config for tor and blockr.
echo "[BLOCKCHAIN]
blockchain_source = blockr 
# blockchain_source options: blockr, bitcoin-rpc, json-rpc, regtest
# for instructions on bitcoin-rpc read https://github.com/chris-belcher/joinmarket/wiki/Running-JoinMarket-with-Bitcoin-Core-full-node 
network = mainnet
rpc_host = localhost
rpc_port = 8332
rpc_user = bitcoin
rpc_password = password

[MESSAGING]
#host = irc.cyberguerrilla.org
channel = joinmarket-pit
port = 6697
usessl = true
socks5 = false
socks5_host = localhost
socks5_port = 9050
# for tor
host = a2jutl5hpza43yog.onion
maker_timeout_sec = 60

[POLICY]
# merge_algorithm options: greedy, default, gradual
merge_algorithm = default" > ../joinmarket/joinmarket.cfg


# Final notes.
echo "
          JOINMARKET SUCCESSFULLY INSTALLED AND CONFIGURED!

          IF YOU HAVE PERSISTENCE ENABLED, AND YOU RAN THIS
       SCRIPT FROM WITHIN THE FOLDER: /home/amnesia/Persistent
        THEN YOUR INSTALL WILL SURVIVE REBOOTS AND YOU NEVER
                   HAVE TO RUN THIS SCRIPT AGAIN.


SOME USEFUL LINKS:

YOUR JOINMARKET FOLDER LOCATION:
$(pwd | sed 's|tailsjoin|joinmarket|')

DETAILED USE GUIDE FOR TAILS (WITH PICTURES):
https://github.com/tailsjoin/tailsjoin/wiki/Detailed-Minimal-Setup-Guide

HIDDEN SERVICE ORDERBOOK WATCHER:
http://ruc47yiosooolrzw.onion

JOINMARKET PROJECT OFFICIAL GITHUB:
https://github.com/chris-belcher/joinmarket
"
read -p "PRESS ENTER TO EXIT. "
exit 0