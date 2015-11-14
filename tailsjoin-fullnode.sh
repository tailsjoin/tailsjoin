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
          THIS SCRIPT WILL INSTALL JOINMARKET, DEPENDENCIES,
              AND BITCOIN CORE. YOU MUST HAVE AT LEAST
                 50GB OF FREE SPACE ON YOUR DEVICE.

             ADMIN PASS WILL BE REQUIRED MULTIPLE TIMES.
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


# Download/verify Bitcoin Core.
echo "
GETTING BITCOIN CORE, CHECKSUM, AND SIGNING KEYS...
"
curl -x socks5://127.0.0.1:9050 -# -L -O https://bitcoin.org/bin/bitcoin-core-0.11.2/bitcoin-0.11.2-linux32.tar.gz -O https://bitcoin.org/bin/bitcoin-core-0.11.2/SHA256SUMS.asc
gpg --recv-keys 01EA5486DE18A882D4C2684590C8019E36C2E964
echo "01EA5486DE18A882D4C2684590C8019E36C2E964:6" | gpg --import-ownertrust -
clear
echo "
VERIFYING SIGNATURE...
"
gpg --verify SHA256SUMS.asc
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
  srm -drv SHA256SUMS.asc
  curl -x socks5://127.0.0.1:9050 -# -L -O https://bitcoin.org/bin/bitcoin-core-0.11.2/SHA256SUMS.asc
  clear
  echo "
VERIFYING CHECKSUMS...
"
  gpg --verify SHA256SUMS.asc
  echo "
PLEASE REVIEW THE TEXT ABOVE.
IT WILL EITHER SAY GOOD SIG OR BAD SIG.
"
  read -p "IS IT A GOOD SIG? (y/n) " x
done
clear
echo "
VERIFYING CHECKSUM OF BITCOIN CORE...
"
sha=$(grep linux32.tar.gz SHA256SUMS.asc | cut -b -64)
echo ""; echo ""$sha"  bitcoin-0.11.2-linux32.tar.gz" | sha256sum -c
echo""; read -p 'DID THAT SHOW: "bitcoin-0.11.2-linux32.tar.gz: OK" ? (y/n) ' x
while [[ "$x" = "n" || "$x" = "N" ]]; do
  clear
  echo "
SECURELY DELETING FILES AND DOWNLOADING AGAIN...
"
  srm -drv bitcoin*.tar.gz
  curl -x socks5://127.0.0.1:9050 -# -L -O https://bitcoin.org/bin/bitcoin-core-0.11.2/bitcoin-0.11.2-linux32.tar.gz
  echo ""; echo ""$sha"  bitcoin-0.11.2-linux32.tar.gz" | sha256sum -c
  echo""; read -p 'DID THAT SHOW: "bitcoin-0.11.2-linux32.tar.gz: OK" ? (y/n) ' x
done
echo "
EXTRACTING BITCOIN CORE, DELETING USELESS FILES...
"
tar xvf bitcoin*.tar.gz
rm -rf bitcoin*.tar.gz SHA256SUMS.asc
mv bitcoin-0.11.2/ ..
clear


# Check for bitcoin.conf
if [ -e "../bitcoin-0.11.2/bin/bitcoin.conf" ]; then
  clear
  echo ""; read -p 'FILE "bitcoin.conf" EXISTS. OVERWRITE? (y/n) ' ow
  if  [[ "$ow" = "n" || "$ow" = "N" ]]; then
    echo ""; read -p "PRESS ENTER TO EXIT SCRIPT."
    exit 0
  fi
fi


# Create a bitcoin.conf.
rpcu=$(pwgen -ncsB 35 1)
rpcp=$(pwgen -ncsB 75 1)
echo "rpcuser="$rpcu"
rpcpassword="$rpcp"
daemon=1
proxyrandomize=1
proxy=127.0.0.1:9050
listen=0
server=1

# For JoinMarket
walletnotify=curl -sI --connect-timeout 1 http://127.0.0.1:62602/walletnotify?%s
alertnotify=curl -sI --connect-timeout 1 http://127.0.0.1:62602/alertnotify?%s

# User must uncomment and input path to blockchain files
#datadir=" > ../bitcoin-0.11.2/bin/bitcoin.conf


# Fix iptables for RPC calls from amnesia.
# This code was lifted from Axis-Mundi README.TAILS (https://github.com/six-pack/Axis-Mundi/blob/master/README.TAILS)
echo "
ENTER PASSWORD TO ADJUST IPTABLES SO USER amnesia CAN TALK TO BITCOIN.
"
sudo iptables -I OUTPUT 2 -p tcp -s 127.0.0.1 -d 127.0.0.1 -m owner --uid-owner amnesia -j ACCEPT
clear


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
curl -x socks5://127.0.0.1:9050 -# -L -O http://download.libsodium.org/libsodium/releases/libsodium-1.0.4.tar.gz -O http://download.libsodium.org/libsodium/releases/libsodium-1.0.4.tar.gz.sig
clear


# Verify download.
echo "
VERIFYING THE DOWNLOAD...
"
gpg --verify libsodium-1.0.4.tar.gz.sig libsodium-1.0.4.tar.gz
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
  curl -x socks5://127.0.0.1:9050 -# -L -O http://download.libsodium.org/libsodium/releases/libsodium-1.0.4.tar.gz -O http://download.libsodium.org/libsodium/releases/libsodium-1.0.4.tar.gz.sig
  gpg --verify libsodium-1.0.4.tar.gz.sig libsodium-1.0.4.tar.gz
  echo "
PLEASE REVIEW THE TEXT ABOVE.
IT WILL EITHER SAY GOOD SIG OR BAD SIG.
"
  read -p "IS IT A GOOD SIG? (y/n) " x
done
clear


# Build and install libsodium.
tar xf libsodium*.tar.gz
rm -rf libsodium*.tar.gz*

if [[ $(pwd | grep -c Persistent) = "1" ]]; then
  echo "
BUILDING AND INSTALLING LIBSODIUM TO SURVIVE REBOOTS...
"
  mkdir ../joinmarket/libsodium
  ( cd libsodium-1.0.4/ && ./configure --prefix=$(pwd) && make && make install )
  mv libsodium-1.0.4/lib/libsodium.* ../joinmarket/libsodium/
  sed -i "s|\/usr\/local\/lib|$(pwd | sed 's|tailsjoin|joinmarket\/libsodium|')|" ../joinmarket/lib/libnacl/__init__.py
  ( cd ../joinmarket && git commit -a -m "Tailsjoin survive reboots" )
else
  echo "
BUILDING LIBSODIUM...
"
  ( cd libsodium-1.0.4/ && ./configure && make )
  echo "
LIBSODIUM SUCCESSFULLY BULIT. ENTER PASSWORD TO INSTALL.
"
  ( cd libsodium-1.0.4/ && sudo make install )
fi
rm -rf libsodium*
clear


# Set JoinMarket config for tor and bitcoin-rpc.
echo "[BLOCKCHAIN]
blockchain_source = bitcoin-rpc
# blockchain_source options: blockr, bitcoin-rpc, json-rpc, regtest
# for instructions on bitcoin-rpc read https://github.com/chris-belcher/joinmarket/wiki/Running-JoinMarket-with-Bitcoin-Core-full-node
network = mainnet
rpc_host = 127.0.0.1
rpc_port = 8332
rpc_user = "$rpcu"
rpc_password = "$rpcp"

[MESSAGING]
#host = irc.cyberguerrilla.org
channel = joinmarket-pit
port = 6697
usessl = true
socks5 = true
socks5_host = 127.0.0.1
socks5_port = 9050
# for tor
host = 6dvj6v5imhny3anf.onion
# The host below is an alternative if the above isn't working.
#host = a2jutl5hpza43yog.onion
maker_timeout_sec = 60

[POLICY]
# merge_algorithm options: greediest, greedy, default, gradual
merge_algorithm = default" > ../joinmarket/joinmarket.cfg


# Final notes.
echo "
          JOINMARKET SUCCESSFULLY INSTALLED AND CONFIGURED!

          IF YOU HAVE PERSISTENCE ENABLED, AND YOU RAN THIS
       SCRIPT FROM WITHIN THE FOLDER: /home/amnesia/Persistent,
               THEN YOUR INSTALL WILL SURVIVE REBOOTS.

YOUR JOINMARKET FOLDER LOCATION:
$(pwd | sed 's|tailsjoin|joinmarket|')

YOUR BITCOIN FOLDER LOCATION:
$(pwd | sed 's|tailsjoin|bitcoin-0.11.2|')

YOUR BITCOIN.CONF LOCATION:
$(pwd | sed 's|tailsjoin|bitcoin-0.11.2\/bin\/bitcoin.conf|')

    YOU MUST NOW ENTER YOUR DATA DIRECTORY (BLOCKCHAIN FILES)
    INTO YOUR BITCOIN.CONF OR BITCOIN WILL START FROM SCRATCH.
    TO RUN BITCOIN, ENTER THE FOLDER:
    $(pwd | sed 's|tailsjoin|bitcoin-0.11.2\/bin|')
    AND DO:
    ./bitcoind -conf=$(pwd | sed 's|tailsjoin|bitcoin-0.11.2\/bin\/bitcoin.conf|')
"
read -p "PRESS ENTER TO EXIT SCRIPT. "
exit 0
