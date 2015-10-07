#!/bin/bash
set -e
clear
echo -e "\n\nYOU ARE CURRENTLY IN THE FOLDER $PWD"
read -p "IS THIS WHERE YOU WANT TO DOWNLOAD BITCOIN? (y/n) " x
if [[ "$x" = "n" || "$x" = "N" ]]; then
  clear
  echo -e "\n\nPLEASE MOVE THE SCRIPT tailsjoin-fullnode.sh TO THE FOLDER WHERE"
  echo -e "BITCOIN WILL GO AND RUN AGAIN.\n\n"
  read -p "PRESS ENTER TO EXIT. "
  exit 0
fi
clear
echo -e "\n\nYOU NOW HAVE THE OPTION OF DOWNLOADING THE STANDARD BITCOIN CORE"
echo -e " CLIENT, OR THE BITCOIN XT CLIENT WITH SUPPORT FOR BIGGER BLOCKS.\n"
read -p "WOULD YOU LIKE TO DOWNLOAD (C)ORE OR (X)T (c/x)? " cx
if [[ "$cx" = "c" || "$cx" = "C" ]]; then
  clear
  echo -e "\n\nPRESS ENTER TO GET BITCOIN CORE AND CHECKSUMS FROM:\n"
  echo "https://bitcoin.org/bin/bitcoin-core-0.11.0/bitcoin-0.11.0-linux32.tar.gz"
  echo "https://bitcoin.org/bin/bitcoin-core-0.11.0/SHA256SUMS.asc "; read
  curl -x socks5://127.0.0.1:9050 -# -L -O https://bitcoin.org/bin/bitcoin-core-0.11.0/bitcoin-0.11.0-linux32.tar.gz -O https://bitcoin.org/bin/bitcoin-core-0.11.0/SHA256SUMS.asc
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
    curl -x socks5://127.0.0.1:9050 -# -L -O https://bitcoin.org/bin/bitcoin-core-0.11.0/SHA256SUMS.asc
    gpg --verify SHA256SUMS.asc
    echo -e "\n\nPLEASE REVIEW THE SIG TO MAKE SURE IT IS GOOD.\n"
    read -p "GOOD SIG? (y/n) " x
  done
  clear
  echo -e "\n\nCHECKING THE SHA256 SUM OF DOWNLOADED BITCOIN CLIENT."
  sha=$(grep linux32.tar.gz SHA256SUMS.asc | cut -b -64)
  echo ""; echo ""$sha"  bitcoin-0.11.0-linux32.tar.gz" | sha256sum -c
  echo""; read -p 'DID THAT SHOW: "bitcoin-0.11.0-linux32.tar.gz: OK" ? (y/n) ' x
  while [[ "$x" = "n" || "$x" = "N" ]]; do
    clear
    echo -e "\n\n"; read -p "PRESS ENTER TO DELETE FILES AND GET AGAIN."
    srm -drv bitcoin-0.11.0-linux32.tar.gz
    curl -x socks5://127.0.0.1:9050 -# -L -O https://bitcoin.org/bin/bitcoin-core-0.11.0/bitcoin-0.11.0-linux32.tar.gz
    echo ""; read -p "PRESS ENTER TO CHECK THE SHA256 SUM OF DOWNLOADED BITCOIN CLIENT."
    sha=$(grep linux32.tar.gz SHA256SUMS.asc | cut -b -64)
    echo ""; echo ""$sha"  bitcoin-0.11.0-linux32.tar.gz" | sha256sum -c
    echo""; read -p 'DID THAT SHOW: "bitcoin-0.11.0-linux32.tar.gz: OK" ? (y/n) ' x
  done
  clear
  echo -e "\n\nPRESS ENTER TO EXTRACT BITCOIN AND DELETE USELESS FILES."; read
  tar -xvf bitcoin-0.11.0-linux32.tar.gz
  rm -rf bitcoin-0.11.0-linux32.tar.gz SHA256SUMS.asc
else
  clear
  echo -e "\n\nPRESS ENTER TO GET BITCOIN XT FROM:\n"
  echo "https://github.com/bitcoinxt/bitcoinxt/releases/download/v0.11A/bitcoin-0.11.0-linux32.tar.gz "; read
  curl -x socks5://127.0.0.1:9050 -# -L -O https://github.com/bitcoinxt/bitcoinxt/releases/download/v0.11A/bitcoin-0.11.0-linux32.tar.gz
  clear
  echo -e "\n\nCHECKING THE SHA256 SUM OF DOWNLOADED BITCOIN CLIENT."
  sha=8705966cd735d5075e17aa03eff1b69c7c765dca5e826d8d849321db0650fc37
  echo ""; echo ""$sha"  bitcoin-0.11.0-linux32.tar.gz" | sha256sum -c
  echo""; read -p 'DID THAT SHOW: "bitcoin-0.11.0-linux32.tar.gz: OK" ? (y/n) ' x
  while [[ "$x" = "n" || "$x" = "N" ]]; do
    clear
    echo -e "\n\n"; read -p "PRESS ENTER TO DELETE FILES AND GET AGAIN. "
    srm -drv bitcoin-0.11.0-linux32.tar.gz
    curl -x socks5://127.0.0.1:9050 -# -L -O https://github.com/bitcoinxt/bitcoinxt/releases/download/v0.11A/bitcoin-0.11.0-linux32.tar.gz
    echo ""; read -p "PRESS ENTER TO CHECK THE SHA256 SUM OF DOWNLOADED BITCOIN CLIENT."
    sha=8705966cd735d5075e17aa03eff1b69c7c765dca5e826d8d849321db0650fc37
    echo ""; echo ""$sha"  bitcoin-0.11.0-linux32.tar.gz" | sha256sum -c
    echo""; read -p 'DID THAT SHOW: "bitcoin-0.11.0-linux32.tar.gz: OK" ? (y/n) ' x
  done
  clear
  echo -e "\n\nPRESS ENTER TO EXTRACT BITCOIN AND DELETE USELESS FILES."; read
  tar -xvf bitcoin-0.11.0-linux32.tar.gz
  rm -rf bitcoin-0.11.0-linux32.tar.gz
fi
clear
rpcu=$(pwgen -ncsB 35 1)
rpcp=$(pwgen -ncsB 75 1)
echo -e "\n\nPRESS ENTER TO PUT THESE SETTINGS IN YOUR BITCOIN.CONF:\n"
bitconf=$(echo -e "daemon=1\nrpcuser="$rpcu"\nrpcpassword="$rpcp"\nproxy=127.0.0.1:9050\nlisten=0\nproxyrandomize=1\nserver=1\n\n# JoinMarket Settings\nwalletnotify=curl -sI --connect-timeout 1 http://127.0.0.1:62602/walletnotify?%s\nalertnotify=curl -sI --connect-timeout 1 http://127.0.0.1:62062/alertnotify?%s\n# User to input blockchain path\ndatadir=")
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
echo -e "\n\nENTER PASSWORD TO ALLOW CALLS TO LOCALHOST BY ADJUSTING IPTABLES AS FOLLOWS:\n"
echo -e "sudo iptables -I OUTPUT 2 -p tcp -s 127.0.0.1 -d 127.0.0.1 -m owner --uid-owner amnesia -j ACCEPT\n"
sudo iptables -I OUTPUT 2 -p tcp -s 127.0.0.1 -d 127.0.0.1 -m owner --uid-owner amnesia -j ACCEPT
clear
echo -e "\n\nNOW WE WILL INSTALL JOINMARKET AND ITS DEPENDENCIES."
echo -e "\nENTER PASSWORD AT PROMPT TO UPDATE SOURCES.\n"
sudo apt-get update
clear
echo -e "\n\nENTER PASSWORD AT PROMPT TO INSTALL THE FOLLOWING DEPENDENCIES:\n"
echo -e "gcc, libc6-dev, make\n"
sudo apt-get install -y gcc libc6-dev make
clear
echo -e "\n\nPRESS ENTER TO CLONE INTO JOINMARKET VIA:\n"
read -p "https://github.com/chris-belcher/joinmarket "
git clone https://github.com/chris-belcher/joinmarket ../joinmarket
# Fetch libsodium and sig, import key, and verify.
clear
echo -e "\n\nPRESS ENTER TO GET SIGNING KEYS AND VERIFY LIBSODIUM SOURCE FROM:\n"
read -p "http://download.libsodium.org/libsodium/releases/libsodium-1.0.3.tar.gz "
gpg --recv-keys 54A2B8892CC3D6A597B92B6C210627AABA709FE1
echo "54A2B8892CC3D6A597B92B6C210627AABA709FE1:6" | gpg --import-ownertrust -
curl -x socks5://127.0.0.1:9050 -# -L -O http://download.libsodium.org/libsodium/releases/libsodium-1.0.3.tar.gz -O http://download.libsodium.org/libsodium/releases/libsodium-1.0.3.tar.gz.sig
gpg --verify libsodium-1.0.3.tar.gz.sig libsodium-1.0.3.tar.gz
echo -e "\n\nPLEASE REVIEW SIGNATURE.\n"
read -p "GOOD SIG? (y/n) " x
while [[ "$x" = "n" || "$x" = "N" ]]; do
  clear
  echo -e "\n\n"
  read -p "PRESS ENTER TO DELETE FILES AND GET AGAIN. "
  srm -drv libsodium*
  curl -x socks5://127.0.0.1:9050 -# -L -O http://download.libsodium.org/libsodium/releases/libsodium-1.0.3.tar.gz -O http://download.libsodium.org/libsodium/releases/libsodium-1.0.3.tar.gz.sig
  gpg --verify libsodium-1.0.3.tar.gz.sig libsodium-1.0.3.tar.gz
  echo -e "\n\nPLEASE REVIEW THE SIG TO MAKE SURE IT IS GOOD.\n"
  read -p "GOOD SIG? (y/n) " x
done
# Build libsodium, install, and delete tar files
tar xf libsodium-1.0.3.tar.gz
rm -rf libsodium-1.0.3.tar.gz*
if [[ $(echo "$PWD" | grep -c Persistent) = "1" ]]; then
  clear
  echo -e "\n\nPRESS ENTER TO BUILD AND INSTALL LIBSODIUM IN A WAY THAT WILL SURVIVE REBOOTS.\n"
  read
  mkdir ../joinmarket/libsodium
  ( cd libsodium-1.0.3/ && ./configure --prefix=$(echo "$PWD") && make && make install )
  mv libsodium-1.0.3/lib/libsodium.* ../joinmarket/libsodium/
  sed -i "s|\/usr\/local\/lib|$(echo "$PWD" | sed 's|tailsjoin|joinmarket\/libsodium|')|" ../joinmarket/lib/libnacl/__init__.py
else
  ( cd libsodium-1.0.3/ && ./configure && make )
  clear
  echo -e "\n\nLIBSODIUM SUCCESSFULLY BULIT. ENTER PASSWORD TO INSTALL.\n"
  ( cd libsodium-1.0.3/ && sudo make install )
fi
rm -rf libsodium-1.0.3/
echo "[BLOCKCHAIN]
blockchain_source = blockr 
# blockchain_source options: blockr, bitcoin-rpc, json-rpc, regtest
# for instructions on bitcoin-rpc read https://github.com/chris-belcher/joinmarket/wiki/Running-JoinMarket-with-Bitcoin-Core-full-node 
network = mainnet
rpc_host = 127.0.0.1
rpc_port = 8332
rpc_user = $rpcu
rpc_password = $rpcp 

[MESSAGING]
#host = irc.cyberguerrilla.org
channel = joinmarket-pit
port = 6697
usessl = true
socks5 = false
socks5_host = 127.0.0.1
socks5_port = 9050
# for tor
host = 6dvj6v5imhny3anf.onion
# The host below is an alternative if the above isn't working.
#host = a2jutl5hpza43yog.onion
maker_timeout_sec = 60

[POLICY]
# merge_algorithm options: greedy, default, gradual
merge_algorithm = default" > ../joinmarket/joinmarket.cfg
clear
echo -e "\n\nJOINMARKET CLONED, AND CONFIG SET TO USE TOR AND BITCOIN RPC!\n"
read -p "PRESS ENTER FOR SOME FINAL NOTES. "
clear
echo -e "\n\nPLEASE GO HERE TO GET DETAILED INFO ON HOW TO OPERATE FROM THE CREATOR:"
echo "https://github.com/chris-belcher/joinmarket/wiki"
echo -e "\nYOU CAN RUN BITCOIN BY ENTERING THE FOLDER:"
echo " $PWD/bitcoin-0.11.0/bin/"
echo "AND USE THIS COMMAND:"
echo "./bitcoind -conf=$PWD/bitcoin-0.11.0/bin/bitcoin.conf"
echo -e "\nYOU MUST NOW ENTER YOUR DATA DIR IN THE BITCOIN CONFIG FILE."
echo -e "EXAMPLE ENTRY:\ndatadir=/media/mounted_device/.bitcoin/\n\n"
read -p "PRESS ENTER TO LEAVE SCRIPT. "
exit 0
