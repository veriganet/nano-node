#!/bin/bash

nanodir="${HOME}/${ABBREVIATION^}"
echo "$(date) - nanodir ${nanodir}"

# get correct private_key by hostname
hostname=$(hostname)
echo "$(date) - hostname ${hostname}"
IFS='-' read -r -a array <<< "${hostname}"
node_number=${array[-1]}

if [ "${node_number}" == 0 ]; then
  echo "PRIVATE_KEY_REP0"
  PRIVATE_KEY=${PRIVATE_KEY_REP0}
elif [ "${node_number}" == 1 ]; then
  echo "PRIVATE_KEY_REP1"
  PRIVATE_KEY=${PRIVATE_KEY_REP1}
elif [ "${node_number}" == 2 ]; then
  echo "PRIVATE_KEY_REP2"
  PRIVATE_KEY=${PRIVATE_KEY_REP2}
fi

# creates nano dir if it does not exist
if [ ! -d "${nanodir}" ]; then
  echo "$(date) - ${nanodir} does not exist!"
  echo "$(date) - Creating directory ${nanodir}"
  mkdir -p "${nanodir}"
fi

# copy default config files to nanodir
if [ ! -f "${nanodir}/config-node.toml" ] && [ ! -f "${nanodir}/config.json" ]; then
	echo "$(date) - Config file not found, adding default."
	cp "/usr/share/nano/config/config-node.toml" "${nanodir}/config-node.toml"
	cp "/usr/share/nano/config/config-rpc.toml" "${nanodir}/config-rpc.toml"
fi

# enable_control
echo "$(date) - enable_control = true"
grep -r -l 'enable_control = false' "${nanodir}" | sort | uniq | xargs perl -e "s/enable_control = false/enable_control = true/" -pi

# run node with enable_control
"${ABBREVIATION}"_node --daemon &

echo "$(date) - Sleeping 5 seconds..."
sleep 5

wallet_id_count=$(wc -c < "${nanodir}/wallet_id")

# check if wallet exist
if [ -f "${nanodir}/wallet_id" ] && [ "${wallet_id_count}" == "65" ]; then
  wallet_id=$(cat "${nanodir}/wallet_id")
  echo "$(date) - Wallet exist! Wallet ID: ${wallet_id}"
  echo "$(date) - Skipping creating wallet."
else
  # create wallet
  echo "$(date) - Wallet does not exist!"
  echo "$(date) - Creating wallet and storing wallet_id."
  curl -g -d '{ "action": "wallet_create" }' --url "http://127.0.0.1:7076" | \
  jq -r '.wallet' > "${nanodir}/wallet_id"
  WALLET_ID=$(cat "${nanodir}/wallet_id")
fi

# get account address character count
account_address_count=$(wc -c < "${nanodir}/account_address")
abbreviation_count=${#ABBREVIATION}
account_address_count_final=$(echo $((${abbreviation_count}+62)))

# add private key to wallet and write to account_address
if [ -f "${nanodir}/account_address" ] &&
  [ "${account_address_count}" == "${account_address_count_final}" ]; then
  account_address=$(cat "${nanodir}/account_address")
  echo "$(date) - Account exist! Account Address: ${account_address}"
  echo "$(date) - Skipping adding private key to wallet!"
else
  echo "$(date) - Account does not exist."
  # add private key to wallet
  echo "$(date) - Adding private key to wallet."
  curl -g \
  --url "http://127.0.0.1:7076" \
  -d '{ "action": "wallet_add", "wallet": "'${WALLET_ID}'", "key": "'${PRIVATE_KEY}'" }' | \
  jq -r '.account' > "${nanodir}/account_address"
  ACCOUNT_ADDRESS=$(cat "${nanodir}/account_address")
  echo "$(date) - Private key added and account created: ${ACCOUNT_ADDRESS}"
fi

# receive pending blocks
echo "$(date) - Searching and receiving pending blocks."
curl -g \
--url "http://127.0.0.1:7076" \
-d '{"action": "search_pending_all"}'

# disable_control
echo "$(date) - enable_control = false"
grep -r -l 'enable_control = true' "${nanodir}" | sort | uniq | xargs perl -e "s/enable_control = true/enable_control = false/" -pi
