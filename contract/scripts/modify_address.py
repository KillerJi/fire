#!/usr/bin/env python3

import os
import json
import subprocess

json_data = {
	"tokens": ["0xb6890808bFd47f38D20c880455e84F7F2d3c5859", "0x3De41eCb6F2cD84b3fBa3aca544D7b8ea742F98A", "0xC91EdDfc4FFc6719340FEe3Ba8d0fADFB53ff8C1"],
	"uni_factory_v1": "0x497634Ef00f780e25969b78d83D509e2a5B19876",
	"uni_exchange_template": "0x778715d782a909B63Ed219a29EB5f685Bf63a849",
	"alice_exchange_address": "0x259Ba3455478C83a53BDDfbB5Bbc84E96607fb6A",
	"bob_exchange_address": "0x778A2A235a086731Cf7F7C16e5fA7D001284Ca9B",
	"uni_factory_v2": "0xAd4E97ad1C744AF7770B64A6f3bcC067Da8C2359",
	"weth": "0x101F42C7f7462E737bE47d326835Ae75389ec2D6",
	"uni_router_v1": "0x3422D8AFE879182C37c86F95EcCfcF4945ec2978",
	"uni_router_v2": "0x2C72CD6e753F9e5C600C713F781C9547BA0843D2",
	"uni_multicall": "0xCf0CCf6Cd0b3D2698D333F3613F50aEfF987f330",
	"uni_migrator": "0x72cA2901D21F6E158199507e90770641Dd7874cC",
	"old_ens": "0x9146d9Adc7dA4E72d6b8903Cb56cf98Fc54d0b26",
	"ens_register": "0xC3855Ab07805f622332AE15514873816aa615787",
	"gas_relay_hub": "0xeD41b678eAd87F8cC9BB13Ab2587BC77A270008a"
}

# Use this API to get ABI and Bytecode
# http://api.etherscan.io/api?module=contract&action=getabi&address=0xTODO&format=raw
v1_mainnet_factory_address = "0xc0a47dFe034B400B47bDaD5FecDa2621de6c4d95"
v2_mainnet_factory_address = "0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f"
v2_mainnet_router_address = "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D"
v2_mainnet_multicall_address = "0xeefBa1e63905eF1D7ACbA5a8513c70307C1cE441"
v2_mainnet_migrator_address = "0x16D4F26C15f3658ec65B1126ff27DD3dF2a2996b"
v2_mainnet_weth_address = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2"
v2_mainnet_registry_address = "0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e"
v2_gas_relay_hub_address = "0xD216153c06E857cD7f72665E0aF1d7D82172F494"

# Factory
sed_command_v1_fac = 's/' + v1_mainnet_factory_address + '/' + json_data["uni_factory_v1"] + '/g'
sed_command_v1_template = 's/0x2157A7894439191e520825fe9399aB8655E0f708/' + json_data["uni_exchange_template"] + '/g'
sed_command_v2_fac = 's/' + v2_mainnet_factory_address + '/' + json_data["uni_factory_v2"] + '/g'
sed_command_v1_rou = 's/0xf164fc0ec4e93095b804a4795bbe1e041497b92a/' + json_data["uni_router_v1"] + '/g'
sed_command_v2_rou = 's/' + v2_mainnet_router_address + '/' + json_data["uni_router_v2"] + '/g'
sed_command_v2_mul = 's/' + v2_mainnet_multicall_address + '/' + json_data["uni_multicall"] + '/g'
sed_command_v2_mig = 's/' + v2_mainnet_migrator_address + '/' + json_data["uni_migrator"] + '/g'
sed_command_v2_wet = 's/' + v2_mainnet_weth_address + '/' + json_data["weth"] + '/g'
sed_command_v2_reg = 's/' + v2_mainnet_registry_address + '/' + json_data["ens_register"] + '/g'
sed_command_v2_gas = 's/' + v2_gas_relay_hub_address + '/' + json_data["gas_relay_hub"] + '/g'

# # Update files
dirs_to_process = ['../../src/', '../../build/', '../../node_modules/@uniswap/']
for individual_dir in dirs_to_process:
    for (root, dirs, files) in os.walk(individual_dir):
        for name in files:
            print("Processing: " + os.path.join(root, name))
            subprocess.call(['sed', '-ir', sed_command_v1_fac, os.path.join(root, name)])
            subprocess.call(['sed', '-ir', sed_command_v1_template, os.path.join(root, name)])
            subprocess.call(['sed', '-ir', sed_command_v2_fac, os.path.join(root, name)])
            subprocess.call(['sed', '-ir', sed_command_v1_rou, os.path.join(root, name)])
            subprocess.call(['sed', '-ir', sed_command_v2_rou, os.path.join(root, name)])
            subprocess.call(['sed', '-ir', sed_command_v2_mul, os.path.join(root, name)])
            subprocess.call(['sed', '-ir', sed_command_v2_mig, os.path.join(root, name)])
            subprocess.call(['sed', '-ir', sed_command_v2_wet, os.path.join(root, name)])
            subprocess.call(['sed', '-ir', sed_command_v2_reg, os.path.join(root, name)])
            subprocess.call(['sed', '-ir', sed_command_v2_gas, os.path.join(root, name)])
            subprocess.call(['sed', '-ir', 's/0x96e8ac4277198ff8b6f785478aa9a39f403cb768dd02cbee326c3e7da348845f/0x930d1385e6f8dd6eee022d15af899c6ef8b37925b77aaaf5f1147940f8a77316/g', os.path.join(root, name)])
# # Clean up r files
the_dict = {}       
for individual_dir in dirs_to_process:
    for (root, dirs, files) in os.walk(individual_dir):
        for name in files:
            diff_file = os.path.join(root, name) + "r"
            temp = subprocess.call(['diff', '-c', os.path.join(root, name), diff_file])
            the_dict[str(os.path.join(root, name))] = temp
            if name.endswith("r"):
                print("Cleaning up old files")
                os.remove(os.path.join(root, name))
print("Files changed ...")
print(the_dict)
