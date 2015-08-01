#!/bin/bash
set -e
echo "YOU ARE CURRENTLY IN THE FILE $(echo "$PWD")"
read -p "IS THIS WHERE YOU WANT TO DOWNLOAD BITCOIN? (y/n) " x
if [[ "$x" = "n" || "$x" = "N" ]]; then
  echo -e "\n\nPLEASE MOVE THIS SCRIPT TO THE FOLDER WHERE"
  echo -e "BITCOIN WILL GO AND RUN AGAIN.\n\n"
  read -p "PRESS ENTER TO EXIT."
  exit 0
fi
echo -e "\n\nPRESS ENTER TO GET BITCOIN CORE AND CHECKSUMS FROM:"
echo "https://bitcoin.org/bin/bitcoin-core-0.11.0/bitcoin-0.11.0-linux32.tar.gz"
echo "https://bitcoin.org/bin/bitcoin-core-0.11.0/SHA256SUMS.asc"; read
wget https://bitcoin.org/bin/bitcoin-core-0.11.0/bitcoin-0.11.0-linux32.tar.gz https://bitcoin.org/bin/bitcoin-core-0.11.0/SHA256SUMS.asc
echo -e "\n\nPRESS ENTER TO IMPORT KEY: 0x90C8019E36C2E964 AND CHECK SIG."; read
gpg --recv-keys 01EA5486DE18A882D4C2684590C8019E36C2E964
gpg --verify SHA256SUMS.asc
echo -e "\n\nPLEASE REVIEW THE SIG TO MAKE SURE IT IS GOOD."
read -p "GOOD SIG? (y/n) " x
if [[ "$x" = "n" || "$x" = "N" ]]; then
  clear
  echo -e "\n\nDELETE FILES USING: srm -drv SHA256SUMS.asc bitcoin-0.11.0-linux32.tar.gz"
  read -p "PRESS ENTER TO EXIT THE SCRIPT. RUN AGAIN AFTER DELETION OF FILES."
  exit 0
fi
echo ""; read -p "PRESS ENTER TO CHECK THE SHA256 SUM OF DOWNLOADED BITCOIN CLIENT."
sha=$(grep linux32.tar.gz SHA256SUMS.asc | cut -b -64)
echo ""; echo ""$sha"  bitcoin-0.11.0-linux32.tar.gz" | shasum -c
echo""; read -p 'DID THAT SHOW: "bitcoin-0.11.0-linux32.tar.gz: OK" ? (y/n) ' x
if [[ "$x" = "n" || "$x" = "N" ]]; then
  clear
  echo -e "\n\nDELETE FILES USING: srm -drv SHA256SUMS.asc bitcoin-0.11.0-linux32.tar.gz"
  read -p "PRESS ENTER TO EXIT THE SCRIPT. RUN AGAIN AFTER DELETION OF FILES."
  exit 0
fi
echo ""; read -p "PRESS ENTER TO EXTRACT BITCOIN AND DELETE USELESS FILES."
tar -xvf bitcoin-0.11.0-linux32.tar.gz
srm -dlrv bitcoin-0.11.0-linux32.tar.gz SHA256SUMS.asc
echo ""; read -p "PRESS ENTER TO PUT SOME SANE DEFAULTS INTO A BITCOIN.CONF FOR YOU."
if [ -e "bitcoin.conf" ]; then
  clear
  echo ""; read -p 'FILE "bitcoin.conf" EXISTS. OVERWRITE? (y/n) ' ow
  if  [[ "$ow" = "n" || "$ow" = "N" ]]; then
    echo ""; read -p "PRESS ENTER TO EXIT SCRIPT"
    exit 0
  fi
fi
echo -e "daemon=1\nrpcuser=$(pwgen -ncsB 35 1)\nrpcpassword=$(pwgen -ncsB 75 1)\nproxy=127.0.0.1:9050\nproxyrandomize=1\ndatadir=\nserver=1\ntxindex=1\nwalletnotify=curl -sI --connect-timeout 1 http://localhost:62602/walletnotify?%s\nalertnotify=curl -sI --connect-timeout 1 http://localhost:62062/alertnotify?%s" > bitcoin-0.11.0/bin/bitcoin.conf
clear
echo -e "\nYOU WILL NEED TO ENTER YOUR DATA DIRECTORY IN THE CONFIG."
echo -e "CONFIG FILE IS LOCATED AT: bitcoin-0.11.0/bin/bitcoin.conf\n\n"
echo -e "\n\nPRESS ENTER TO ALLOW RPC CALLS BY ADJUSTING IPTABLES USING THIS COMMAND:\n"
read -p "sudo iptables -I OUTPUT -p tcp -d 127.0.0.1 --dport 8332 -m owner --uid-owner amnesia -j ACCEPT"
sudo iptables -I OUTPUT -p tcp -d 127.0.0.1 --dport 8332 -m owner --uid-owner amnesia -j ACCEPT
echo -e "\n\nPRESS ENTER TO ALLOW JOINMARKET TO COMMUNICATE WITH BITCOIN USING THIS COMMAND:\n"
read -p "sudo iptables -I OUTPUT -p tcp -d 127.0.0.1 --dport 62062 -m owner --uid-owner amnesia -j ACCEPT"
sudo iptables -I OUTPUT -p tcp -d 127.0.0.1 --dport 8332 -m owner --uid-owner amnesia -j ACCEPT
clear
echo -e "\nNOW WE WILL INSTALL JOINMARKET AND ITS DEPENDENCIES."
echo -e "\nENTER PASSWORD AT PROMPT TO UPDATE SOURCES.\n"
sudo apt-get update
echo -e "\nENTER PASSWORD AT PROMPT TO INSTALL THE FOLLOWING DEPENDENCIES:"
echo -e "gcc, libc6-dev, make, python-dev, python-pip\n"
sudo apt-get install -y gcc libc6-dev make python-dev python-pip
echo -e "\nPRESS ENTER TO FETCH LIBSODIUM SOURCE FROM:"
echo -e "http://download.libsodium.org/libsodium/releases/libsodium-1.0.3.tar.gz\n"; read
wget http://download.libsodium.org/libsodium/releases/libsodium-1.0.3.tar.gz http://download.libsodium.org/libsodium/releases/libsodium-1.0.3.tar.gz.sig
gpg --recv-keys 0x62F25B592B6F76DA
gpg --verify libsodium-1.0.3.tar.gz.sig libsodium-1.0.3.tar.gz
echo -e "\nPLEASE REVIEW SIGNATURE. IF THE SIG IS GOOD PRESS ENTER."
echo "IF NOT PRESS CTRL-C AND DO:"
echo "srm -drv libsodium*"
echo -e 'THEN RUN THE "tailsjoin.sh" SCRIPT, NOT THIS SCRIPT.'; read
tar xf libsodium-1.0.3.tar.gz; srm -drv libsodium-1.0.3.tar.gz*
( cd libsodium-1.0.3/ && ./configure )
( cd libsodium-1.0.3/ && make )
echo -e "\nENTER PASSWORD AT PROMPT TO INSTALL LIBSODIUM.\n"
( cd libsodium-1.0.3/ && sudo make install )
echo -e "\nCLEANING UP TEMP FILES...\n"
srm -dlrv libsodium-1.0.3/
echo -e "\nENTER PASSWORD AT PROMPT TO UPGRADE NUMPY TO VERSION 1.9.2\n"
sudo torify pip install numpy --upgrade
echo -e "\nPRESS ENTER TO CLONE INTO JOINMARKET VIA:"
echo -e "https://github.com/chris-belcher/joinmarket\n"; read
git clone https://github.com/chris-belcher/joinmarket joinmarket
echo -e "[BLOCKCHAIN]\nblockchain_source = json-rpc\n#options: blockr, json-rpc, regtest\n#before using json-rpc read https://github.com/chris-belcher/joinmarket/wiki/Running-JoinMarket-with-Bitcoin-Core-full-node\nnetwork = mainnet\nbitcoin_cli_cmd = $PWD/bitcoin-0.11.0/bin/bitcoin-cli -conf=$PWD/bitcoin-0.11.0/bin/bitcoin.conf\n\n[MESSAGING]\n#for clearnet\n#host = irc.cyberguerrilla.info\nchannel = joinmarket-pit\nusessl = true\n#for tor\nsocks5 = false\nsocks5_host = 127.0.0.1\nsocks5_port = 9050\n#host = 6dvj6v5imhny3anf.onion\nhost = a2jutl5hpza43yog.onion\n#socks5 = true\nport = 6697\n" > ../joinmarket/joinmarket.cfg
echo -e "\nJOINMARKET INSTALLED, AND CONFIG SET TO USE TOR."
echo "PLEASE GO HERE TO GET INFO ON HOW TO OPERATE:"
echo "https://github.com/chris-belcher/joinmarket/wiki"
echo -e "PRESS ENTER TO EXIT."; read; exit 0
echo -e "\n\nSCRIPT FINISHED.\n"
echo "YOU CAN RUN BITCOIN BY ENTERING THE FOLDER: bitcoin-0.11.0/bin"
echo "AND DOING: ./bitcoind -conf=/path/to/bitcoin-0.11.0/bin/bitcoin.conf"
echo -e "PROVIDED THAT YOU ENTERED YOUR DATA DIR IN THE CONFIG FILE.\n\n"
read -p "PRESS ENTER TO LEAVE SCRIPT."
exit 0
