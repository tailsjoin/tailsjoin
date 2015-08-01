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
echo -e "daemon=1\nrpcuser=$(pwgen -ncsB 35 1)\nrpcpassword=$(pwgen -ncsB 75 1)\nproxy=127.0.0.1:9050\nproxyrandomize=1\ndatadir=" > bitcoin-0.11.0/bin/bitcoin.conf
clear
echo -e "\nYOU WILL NEED TO ENTER YOUR DATA DIRECTORY IN THE CONFIG."
echo -e "CONFIG FILE IS LOCATED AT: bitcoin-0.11.0/bin/bitcoin.conf\n\n"
echo -e "PRESS ENTER TO ALLOW RPC CALLS BY ADJUSTING IPTABLES USING THIS COMMAND:\n"
read -p "sudo iptables -I OUTPUT -p tcp -d 127.0.0.1 --dport 8332 -m owner --uid-owner amnesia -j ACCEPT"
sudo iptables -I OUTPUT -p tcp -d 127.0.0.1 --dport 8332 -m owner --uid-owner amnesia -j ACCEPT
clear
echo -e "\n\nSCRIPT FINISHED.\n"
echo "YOU CAN RUN BITCOIN BY ENTERING THE FOLDER: bitcoin-0.11.0/bin"
echo "AND DOING: ./bitcoind -conf=/path/to/bitcoin-0.11.0/bin/bitcoin.conf"
echo -e "PROVIDED THAT YOU ENTERED YOUR DATA DIR IN THE CONFIG FILE.\n\n"
read -p "PRESS ENTER TO LEAVE SCRIPT."
exit 0
