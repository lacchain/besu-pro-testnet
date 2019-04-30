#!/bin/bash

#
# This is used to run the constellation and geth node
#

set -u
set -e

### Configuration Options
TMCONF=/lacchain/configuration.conf

GETH_ARGS="--datadir /lacchain/data --networkid 82584648529 --identity $IDENTITY --permissioned --rpc --rpcaddr 0.0.0.0 --rpcapi admin,db,eth,debug,miner,net,shh,txpool,personal,web3,quorum,istanbul --rpcport 22000 --port 21000 --istanbul.requesttimeout 10000 --ethstats $IDENTITY:bb98a0b6442386d0cdf8a31b267892c1@35.231.29.1 --verbosity 3 --vmdebug --emitcheckpoints --targetgaslimit 18446744073709551615 --syncmode full --vmodule consensus/istanbul/core/core.go=5 --mine --minerthreads 1"

if [ ! -d /lacchain/data/constellation ]; then
  mkdir -p /lacchain/data/constellation/{data,keystore}
  mkdir -p /lacchain/logs
fi

if [ ! -d /lacchain/data/geth/chaindata ]; then
  echo "[*] Mining Genesis block"
  /usr/local/bin/geth --datadir /lacchain/data init /lacchain/data/genesis.json
fi

if [ ! -e /lacchain/data/constellation/keystore/node.pub ]; then
  echo "[*] Generating constellation keys"
  cd /lacchain/data/constellation/keystore
  cat /lacchain/.account_pass | constellation-node --generatekeys=node
fi

echo "[*] Starting Constellation node"
nohup /usr/local/bin/constellation-node $TMCONF 2>> /lacchain/logs/constellation.log &

sleep 5

echo "[*] Starting node"
PRIVATE_CONFIG=$TMCONF nohup /usr/local/bin/geth $GETH_ARGS 2>>/lacchain/logs/geth.log