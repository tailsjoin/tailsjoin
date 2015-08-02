#!/bin/bash
set -e
#This script will clone and install pycoin (https://github.com/richardkiss/pycoin), create, sign, and push a transaction in order to clean up your JoinMarket wallet. This is specifically for use with bitcoin core and the Tails live operating system (https://tails.boum.org), and will not work without a local bitcoin client. I may make one that uses a web service too. When either a tumble session fails, or when acting as a maker one often ends up with random funds spread accross random depths. This is hopefully a simple way to reallocate or move these funds. Nothing is ever pushed to the network until you give the "OK" at the very end of the script. So there is no worry in testing, quiting, and testing again.
#
# Use at your own risk, and be aware of your own skill level. Keep a calculator handy as the script does not do math for you.
#
clear
if [[ ! -e pycoin/pycoin/scripts/tx.py ]]; then
  echo -e "\n\nIT SEEMS YOU DON'T HAVE PYCOIN.\n"
  read -p "DO YOU NEED TO GET/BUILD PYCOIN? (y/n) " ip
  if [[ "$ip" = "y" || "$ip" = "Y" ]]; then
    echo -e "\n\nPRESS ENTER TO GET PYCOIN FROM:"
    read -p "https://github.com/richardkiss/pycoin"
    git clone https://github.com/richardkiss/pycoin
    ( cd pycoin/ && sudo python setup.py install )
  fi
fi
clear
echo -e "\n\nPLEASE ENTER THE PATH TO BITCOIN CORE BIN."
echo "EXAMPLE: /home/amnesia/Persistent/bitcoin-0.11.0/bin/"
read btc
h=$(ls "$btc" | grep -c bitcoin-cli)
until [[ "$h" = "1" ]]; do
  echo "THAT PATH DOESN'T CONTAIN bitcoin-cli"
  echo -e "\n\nPLEASE ENTER THE PATH TO BITCOIN CORE BIN."
  echo "EXAMPLE: /home/amnesia/Persistent/bitcoin-0.11.0/bin/"
  read btc
  h=$(ls "$btc" | grep -c bitcoin-cli)
done
clear
echo -e "\n\nPLEASE ENTER THE PATH TO YOUR BITCOIN CONFIG FILE."
echo "EXAMPLE: /home/amnesia/Persistent/bitcoin-0.11.0/bin/bitcoin.conf"
read conf
while [[ ! -e "$conf" ]]; do
  echo "\n\nFILE DOES NOT EXIST!"
  echo -e "\n\nPLEASE ENTER THE PATH TO YOUR BITCOIN CONFIG FILE."
  echo "EXAMPLE: /home/amnesia/Persistent/bitcoin-0.11.0/bin/bitcoin.conf"
  read conf
done
clear
echo -e "\n\nPRESS ENTER TO TEST THAT BITCOIN CORE IS RUNNING,"
read -p "AND THAT WE CAN MAKE CALLS TO IT."
( cd "$btc" && ./bitcoin-cli -conf="$conf" getinfo )
echo -e "\n\nTHAT SHOULD HAVE SHOWN THE INFO ABOUT YOUR RUNNING BITCOIN CORE.\n"
read -p "WERE YOU SUCCESSFULLY SHOWN THE INFO? (y/n) " x
if [[ "$x" = "n" || "$x" = "N" ]]; then
  clear
  echo -e "\n\nSOMETHING IS WRONG WITH THE WAY YOU HAVE BITCOIN CORE SET UP,"
  echo "OR YOU SIMPLY DIDN'T START THE BITCOIN SERVER. CHECK TO MAKE SURE"
  echo -e "THAT YOU HAVE THE DATA DIRECTORY STATED IN YOUR CONFIG FILE.\n"
  read -p "PRESS ENTER TO LEAVE THE SCRIPT AND FIX THINGS."
  exit 0
fi
clear
echo -e "\n\nPLEASE ENTER THE PATH TO YOUR JOINMARKET FOLDER."
echo "EXAMPLE: /home/amnesia/Persistent/joinmarket/"
read jm
h=$(ls "$jm" | grep -c wallet-tool.py)
until [[ "$h" = "1" ]]; do
  echo "THAT PATH DOESN'T CONTAIN wallet-tool.py"
  echo -e "\n\nPLEASE ENTER THE PATH TO YOUR JOINMARKET FOLDER."
  echo "EXAMPLE: /home/amnesia/Persistent/joinmarket/"
  read jm
  h=$(ls "$jm" | grep -c wallet-tool.py)
done
clear
echo -e "\n\nPLEASE ENTER YOUR WALLET FILE NAME."
echo "EXAMPLE: mywallet.json"
read w
while [[ ! -e "$jm"wallets/"$wa" ]]; do
  echo -e"\n\nFILE DOES NOT EXIST!\n"
  echo "PLEASE ENTER YOUR WALLET FILE NAME."
  echo "EXAMPLE: mywallet.json"
  read w
done
clear
echo -e "\n\nWE SHOULD BE ALL SET TO START MOVING FUNDS NOW.\n"
echo -e "WE WILL MAKE THREE TEMP FILES DURING THIS PROCESS:"
echo "/tmp/priv, /tmp/mktx, and /tmp/send"
echo -e "\nALL WILL BE DELETED IF YOU FINISH THE SCRIPT. HOWEVER"
echo -e "IF YOU NEED TO QUIT IN THE MIDDLE, YOU SHOULD DELETE THESE YOURSELF.\n"
read -p "PRESS ENTER TO START REALLOCATING FUNDS."
clear
echo -e "\n\nPLEASE BE PATIENT AFTER ENTERING YOUR WALLET PASSPHRASE"
echo -e "WHILE YOUR ADDRESSES ARE CHECKED FOR FUNDS.\n"
all=$(cd "$jm" && python wallet-tool.py -p "$w")
sum=$(echo "$all" | grep -e "used" -e "balance")
mktx(){
echo "$sum"; echo ""
read -p "ADDRESS TO MOVE FUNDS FROM: " addr
echo "$sum" | grep "$addr" | cut -b 70- > /tmp/priv
unspent=$(cd "$btc" && ./bitcoin-cli -conf="$conf" listunspent 0 999999 [\"$addr\"] | tr -d "\,\"\-\{\}\[\]" | tr -d " ")
tx=$(echo "$unspent" | grep -e "txid" -e "vout" -e "amount" -e "scriptPubKey" | sed -e 's|txid\:| |' -e 's|vout\:|\/|' -e 's|amount\:|\/|' -e 's|scriptPubKey\:|\/|' -e 's|0\.0000000||' -e 's|0\.000000||' -e 's|0\.00000||' -e 's|0\.0000||' -e 's|0\.000||' -e 's|0\.00||' -e 's|0\.0||' -e 's|0\.||' | tr -d "\." | xargs | sed 's| \/|\/|g')
echo -e "\n$tx\n"
echo "$tx" > /tmp/mktx
read -p "ANOTHER ADDRESS TO MOVE FROM? (y/n) " an
until [ "$an" = "n" ]; do
  read -p "NEXT ADDRESS TO MOVE FROM: " addr
  echo "$sum" | grep "$addr" | cut -b 70- >> /tmp/priv
  unspent=$(cd "$btc" && ./bitcoin-cli -conf="$conf" listunspent 0 999999 [\"$addr\"] | tr -d "\,\"\-\{\}\[\]" | tr -d " ")
  tx=$(echo "$unspent" | grep -e "txid" -e "vout" -e "amount" -e "scriptPubKey" | sed -e 's|txid\:| |' -e 's|vout\:|\/|' -e 's|amount\:|\/|' -e 's|scriptPubKey\:|\/|' -e 's|0\.0000000||' -e 's|0\.000000||' -e 's|0\.00000||' -e 's|0\.0000||' -e 's|0\.000||' -e 's|0\.00||' -e 's|0\.0||' -e 's|0\.||' | tr -d "\." | xargs | sed 's| \/|\/|g')
  echo -e "\n$tx\n"
  echo "$tx" >> /tmp/mktx
  read -p "ANOTHER ADDRESS? (y/n) " an
done
clear
utxos=$(cat /tmp/mktx | xargs)
echo -e "\n\nFRESH ADDRESSES IN YOUR JOINMARKET WALLET:\n"
echo "$all" | grep new | cut -b -65
echo -e "\n\nYOUR TRANSACTION SO FAR:\n"
echo -e "tx "$utxos"\n"
read -p "ADDRESS TO SEND TO: " saddr
read -p "AMOUNT IN SATOSHIS TO SEND TO THIS ADDRESS: " samount
echo ""$saddr"/"$samount"" > /tmp/send
echo ""; read -p "SEND TO ANOTHER ADDRESS? (y/n) " an
until [ "$an" = "n" ]; do
  read -p "NEXT ADDRESS TO SEND TO: " saddr
  read -p "AMOUNT IS SATOSHIS TO SEND TO THIS ADDRESS: " samount
  echo ""$saddr"/"$samount"" >> /tmp/send
  echo ""; read -p "ANOTHER ADDRESS? (y/n) " an
done
sends=$(cat /tmp/send | xargs)
clear
echo -e "\n\nTRANSACTION SO FAR:\n"
echo -e "tx "$utxos" "$sends"\n"
read -p "PRESS ENTER TO CREATE THE TRANSACTION. ENTER ADMIN PASS AT PROMPT."
mtx=$(sudo tx $(echo -n ""$utxos" "$sends""))
echo -e "\n\n"
echo -e "$mtx"
}
mktx
echo -e "\n\nPLEASE REVIEW THE INFORMATION IN THE TRANSACTION.\n"
read -p "(S)IGN TX, OR  (R)EMAKE TX? (S/R) " sr
until [ "$sr" = "S" ]; do
mktx
echo -e "\n\nPLEASE REVIEW THE INFORMATION IN THE TRANSACTION.\n"
read -p "(S)IGN TX, OR  (R)EMAKE TX? (S/R) " sr
done
clear
mtxh=$(echo "$mtx" | tail -n 1)
stx=$(sudo tx -f /tmp/priv $(echo -n ""$mtxh""))
echo -e "\n\n"
echo -e "$stx"
echo -e "\n\nPLEASE REVIEW THE SIGNED TRANSACTION.\n"
read -p "PUSH SIGNED TX NOW? (y/n)" ptx
if [[ "$ptx" = "n" || "$ptx" = "N" ]]; then
  read -p "DESTROY TEMP FILES? (y/n) " d
  if  [[ "$d" = "y" ]]; then
    srm -drv /tmp/priv /tmp/send /tmp/mktx
    exit 0
  else
    exit 0
  fi
else
  stxh=$(echo "$stx" | tail -n 1)
  txid=$(cd "$btc" && ./bitcoin-cli -conf="$conf" sendrawtransaction "$stxh")
  clear
  echo -e "\n\nTRANSACTION PUSHED. TXID:  "$txid"\n"
  read -p "DESTROY TEMP FILES? (y/n) " d
  if  [[ "$d" = "y" ]]; then
    srm -drv /tmp/priv /tmp/send /tmp/mktx
    exit 0
  else
    exit 0
  fi
fi
