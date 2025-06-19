#!/bin/bash
# Deploy script
sozo build
sozo migrate apply
sozo execute dice_chess_actions create_game --account-address $ACCOUNT_ADDRESS
