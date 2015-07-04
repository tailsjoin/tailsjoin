#!/bin/bash
set -e
echo -e "\nTHIS SCRIPT WILL INSTALL JOINMARKET AND ITS DEPENDENCIES FOR TAILS OS."
echo "IF YOU ARE USING PERSISTENCE YOU MAY WANT TO MOVE THIS SCRIPT TO:"
echo "/home/amnesia/Persistent"
echo -e "AND THEN RUN IT AGAIN.\n"
# Update
echo -e "\nENTER PASSWORD AT PROMPT TO UPDATE SOURCES.\n"
sudo apt-get update
# Install dependencies available with apt-get
echo -e "\nENTER PASSWORD AT PROMPT TO INSTALL THE FOLLOWING DEPENDENCIES:"
echo -e "gcc, libc6-dev, make, python-dev, python-pip\n"
sudo apt-get install -y gcc libc6-dev make python-dev python-pip
# Fetch libsodium and sig, import key, and verify.
echo -e "\nPRESS ENTER TO FETCH LIBSODIUM SOURCE FROM:"
echo -e "http://download.libsodium.org/libsodium/releases/libsodium-1.0.3.tar.gz\n"; read
wget http://download.libsodium.org/libsodium/releases/libsodium-1.0.3.tar.gz http://download.libsodium.org/libsodium/releases/libsodium-1.0.3.tar.gz.sig
gpg --recv-keys 0x62F25B592B6F76DA
gpg --verify libsodium-1.0.3.tar.gz.sig libsodium-1.0.3.tar.gz
echo -e "\nPLEASE REVIEW SIGNATURE. IF THE SIG IS GOOD PRESS ENTER."
echo "IF NOT PRESS CTRL-C AND DO:"
echo "srm -drv libsodium*"
echo -e "THEN RUN THE SCRIPT AGAIN."; read
# Build libsodium, install, and delete tar files
tar xf libsodium-1.0.3.tar.gz; srm -drv libsodium-1.0.3.tar.gz*
( cd libsodium-1.0.3/ && ./configure )
( cd libsodium-1.0.3/ && make )
echo -e "\nENTER PASSWORD AT PROMPT TO INSTALL LIBSODIUM.\n"
( cd libsodium-1.0.3/ && sudo make install )
srm -drv libsodium-1.0.3/
# Use pip to upgrade numpy
echo -e "\nENTER PASSWORD AT PROMPT TO UPGRADE NUMPY TO VERSION 1.9.2\n"
sudo torify pip install numpy --upgrade
# Clone into joinmarket
echo -e "\nPRESS ENTER TO CLONE INTO JOINMARKET VIA:"
echo -e "https://github.com/chris-belcher/joinmarket\n"; read
git clone https://github.com/chris-belcher/joinmarket
# Set config for tor and blockr. Tails users should consider using an external hdd with bitcoin core.
echo -e "[BLOCKCHAIN]\nblockchain_source = blockr\n#options: blockr, json-rpc, regtest\n#before using json-rpc read https://github.com/chris-belcher/joinmarket/wiki/Running-JoinMarket-with-Bitcoin-Core-full-node\nnetwork = mainnet\nbitcoin_cli_cmd = bitcoin-cli\n\n[MESSAGING]\n#for clearnet\n#host = irc.cyberguerrilla.info\nchannel = joinmarket-pit\nusessl = true\n#for tor\nsocks5 = true\nsocks5_host = 127.0.0.1\nsocks5_port = 9050\n#for tor\n#host = 6dvj6v5imhny3anf.onion\nhost = a2jutl5hpza43yog.onion\nsocks5 = true\nport = 6697\n" > joinmarket/joinmarket.cfg
echo -e "\nJOINMARKET INSTALLED, AND CONFIG SET TO USE TOR."
echo "PLEASE GO HERE TO GET INFO ON HOW TO OPERATE:"
echo "https://github.com/chris-belcher/joinmarket/wiki"
echo -e "PRESS ENTER TO EXIT."; read; exit 0
