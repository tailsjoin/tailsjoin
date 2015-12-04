#[tailsjoin](https://github.com/tailsjoin/tailsjoin/wiki)
##Scripts to install [JoinMarket](https://github.com/chris-belcher/joinmarket), [libsodium](https://download.libsodium.org/doc/), and [Bitcoin Core](https://bitcoin.org/en/download) on the [Tails OS](https://tails.boum.org).

###Options for TAILS:

1. Run `tailsjoin.sh` on a minimal system without enough disk space to store the blockchain. This will use blockr.io (Coinbase) to check address balances and confirmed transactions. This is over Tor, of course, but still not optimal for privacy. [Detailed Guide Minimal](https://tailsjoin.github.io/guides/install_guide.html#withoutbitcoin)

2. Run `tailsjoin-fullnode.sh` on either a system with enough disk space to hold the blockchain, or a minimal system with enough external storage to store the blockchain (50GB~). This is the suggested method for privacy and true control. [Detailed Guide Full Node](https://tailsjoin.github.io/guides/install_guide.html#withbitcoin)

---

###For a minimal system follow the steps below, or use the guides in the wiki.

You must start Tails with "More options" setting in the beginning (Persistence is optional) and set an administrator password no matter which script you run.

All scripts are signed with my gpg key: [`44C5 398E A821 BB41 A0C0  7052 1B91 84DF 9E11 7718`](https://github.com/tailsjoin/tailsjoin/wiki/GnuPG-Key)

1. `cd /home/amnesia/Persistent` (optional)
2. `git clone https://github.com/tailsjoin/tailsjoin`
3. `cd tailsjoin`
4. `gpg --recv-keys 44C5398EA821BB41A0C070521B9184DF9E117718`
5. `gpg --verify tailsjoin.sh.asc tailsjoin.sh`
6. `./tailsjoin.sh`
    
Be aware, the script will prompt for the administrator password several times throughout.

After installation you will have to add `torify` to every command that does blockchain lookups. [Detailed explanation](https://github.com/tailsjoin/tailsjoin/commit/0b42441277dfe77bccfefe6075cb688c0b603e4a).

Examples:

    torify python wallet-tool.py <wallet_file>
    torify python sendpayment.py -N 4 <amount> <destination_address>

---

####[Detailed install and send payment guide.](https://github.com/tailsjoin/tailsjoin/wiki/Detailed-Minimal-Setup-Guide)

####[Orderbook Watcher Hidden Service](http://ruc47yiosooolrzw.onion/)

####[tailsjoin.github.io](https://tailsjoin.github.io) (guides and stuff, under construction)

---

####Tailsjoin donation address: `17SidXk5PTGeVgfGg1DC2a2ryduJ3ajtad`

---

##Official JoinMarket Project Information:

IRC: `#joinMarket` on irc.freenode.net https://webchat.freenode.net/?channels=%23joinmarket

Bitcointalk thread: https://bitcointalk.org/index.php?topic=919116.msg10096563

Subreddit: https://reddit.com/r/joinmarket

Twitter: https://twitter.com/joinmarket

JoinMarket Donation address: `1AZgQZWYRteh6UyF87hwuvyWj73NvWKpL`

####[JOINMARKET OFFICIAL WIKI FOR DETAILED ARTICLES/GUIDES](https://github.com/chris-belcher/joinmarket/wiki)

---

####Consider donating to JoinMarket development when using the tumbler. 

#####To opt-in, run the tumbler like this (with `x.x` being your donation percent):

    torify python tumbler.py --donateamount=x.x
    
---

The tailsjoin project has absolutely no affiliation with the Tails operating system.

These are simply resources for end users to easily and safely anonymize their Bitcoin transactions using existing tools. Pull requests are always appreciated.

---

            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE 
                        Version 2, December 2004 
    
     Copyright (C) 2004 Sam Hocevar <sam@hocevar.net> 
    
     Everyone is permitted to copy and distribute verbatim or modified 
     copies of this license document, and changing it is allowed as long 
     as the name is changed. 
    
                DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE 
       TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION 
    
      0. You just DO WHAT THE FUCK YOU WANT TO.
