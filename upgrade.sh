#!/bin/bash
GREEN_COLOR='\033[0;32m'
RED_COLOR='\033[0;31m'
NO_COLOR='\033[0m'
BLOCK=580000
VERSION=v0.0.2
echo -e "$GREEN_COLOR YOUR NODE WILL BE UPDATED TO VERSION: $VERSION ON BLOCK NUMBER: $BLOCK $NO_COLOR\n"
for((;;)); do
	height=$(empowerd status |& jq -r ."SyncInfo"."latest_block_height")
	if ((height>=$BLOCK)); then
	
		sudo systemctl stop empowerd
		cd $HOME && rm -rf empowerchain
		git clone https://github.com/empowerchain/empowerchain && cd empowerchain
		git checkout v0.0.2
		cd chain
		make build
		sudo mv build/empowerd $(which empowerd)
		echo "restart the system..."
		sudo systemctl restart empowerd && journalctl -fu empowerd -o cat

		for (( timer=60; timer>0; timer-- )); do
			printf "* second restart after sleep for ${RED_COLOR}%02d${NO_COLOR} sec\r" $timer
			sleep 1
		done
		height=$(empowerd status |& jq -r ."SyncInfo"."latest_block_height")
		if ((height>$BLOCK)); then
			echo -e "$GREEN_COLOR YOUR NODE WAS SUCCESFULLY UPDATED TO VERSION: $VERSION $NO_COLOR\n"
		fi
		empowerd version --long | head
		break
	else
		echo -e "${GREEN_COLOR}$height${NO_COLOR} ($(( BLOCK - height  )) blocks left)"
	fi
	sleep 5
done
