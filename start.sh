cd /root/regtest-server/

export NVM_DIR="$HOME/.nvm" && \
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" >/dev/null 2>&1 && \
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" >/dev/null 2>&1

bitcoind -server -regtest -txindex -zmqpubhashtx=tcp://127.0.0.1:30001 -zmqpubhashblock=tcp://127.0.0.1:30001 -rpcworkqueue=32 >/dev/null 2>&1 &
sleep 1.4
echo "Running Bitcoin regtest"
until bitcoin-cli -regtest generate 500 >/dev/null 2>&1
do
  sleep 0.1
done
echo "Done mining 500 blocks"

echo "Starting node app..."
export RPCCOOKIE=/root/.bitcoin/regtest/.cookie
export KEYDB=/root/KEYS
export INDEXDB=/root/db
export ZMQ=tcp://127.0.0.1:30001
export RPCCONCURRENT=32
export RPC=http://localhost:18443
node index.js
