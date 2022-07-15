#!/usr/bin/env python3

import os
import subprocess

one_to_two = "MAINNET \= 1"
one_to_two_II = "chainId\:\"1\""
one_to_two_III = "chainId\:1"
one_to_two_IV ="1\: \'mainnet\'"
one_to_two_V = "1\:\"0xa80171aB64F9913C5d0Df5b06D00030B4febDD6A\""
one_to_two_VI = "1\: \"0xa80171aB64F9913C5d0Df5b06D00030B4febDD6A\""

new_value = "MAINNET \= 256"
new_value_II = "chainId\:\"256\""
new_value_III = "chainId\:256"
new_value_IV = "256\: \'mainnet\'"
new_value_V = "256\:\"0xa80171aB64F9913C5d0Df5b06D00030B4febDD6A\""
new_value_VI = "256\:\"0xa80171aB64F9913C5d0Df5b06D00030B4febDD6A\""

sed_command_I = 's/' + one_to_two + '/' + new_value + '/g'
sed_command_chain_II = 's/' + one_to_two_II + '/' + new_value_II + '/g'
sed_command_chain_III = 's/' + one_to_two_III + '/' + new_value_III + '/g'
sed_command_chain_IV = 's/' + one_to_two_IV + '/' + new_value_IV + '/g'
sed_command_chain_V = 's/' + one_to_two_V + '/' + new_value_V + '/g'
sed_command_chain_VI = 's/' + one_to_two_VI + '/' + new_value_VI + '/g'
sed_command_chain_VII = 's/REACT_APP_CHAIN_ID="1"/REACT_APP_CHAIN_ID="256"/g'
# # Update files
dirs_to_process = ['../../src/', '../../build/', '../../node_modules/@uniswap/']
for individual_dir in dirs_to_process:
    for (root, dirs, files) in os.walk(individual_dir):
        for name in files:
            print("Processing: " + os.path.join(root, name))
            subprocess.call(['sed', '-ir', sed_command_I, os.path.join(root, name)])
            subprocess.call(['sed', '-ir', sed_command_chain_II, os.path.join(root, name)])
            subprocess.call(['sed', '-ir', sed_command_chain_III, os.path.join(root, name)])
            subprocess.call(['sed', '-ir', sed_command_chain_IV, os.path.join(root, name)])
            subprocess.call(['sed', '-ir', sed_command_chain_V, os.path.join(root, name)])
            subprocess.call(['sed', '-ir', sed_command_chain_VI, os.path.join(root, name)])
            subprocess.call(['sed', '-ir', sed_command_chain_VII, os.path.join(root, name)])
            subprocess.call(['sed', '-ir', 's#https://mainnet.infura.io/v3/099fc58e0de9451d80b18d7c74caa7c1#REACT_APP_NETWORK_URL="http://192.168.2.40:8545#g', os.path.join(root, name)])
# Clean up old files
for individual_dir in dirs_to_process:
    for (root, dirs, files) in os.walk(individual_dir):
        for name in files:
            if name.endswith("r"):
                print("Cleaning up old files")
                os.remove(os.path.join(root, name))