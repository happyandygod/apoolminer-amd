#!/usr/bin/env bash

algo='qubic'
stats=""
khs=0

source /hive/miners/custom/apoolminer-amd/h-manifest.conf

gpus_raw=`curl -s --connect-timeout 3 --max-time 5 http://127.0.0.1:$MINER_REST_PORT/gpu`

if [[ $? -ne 0 || -z $gpus_raw ]]; then
  echo -e "${RED}Failed to get gpus info from 127.0.0.1:$MINER_REST_PORT/gpu${NOCOLOR}"
else
  data=`echo "$gpus_raw" | jq -cr '.data'`
  readarray -t temp_data < <(echo "$data" | jq -cr '.uptime, ([.gpus[].proof]|add/1000), [.gpus[].proof], [.gpus[].ctmp], [.gpus[].fan], ([.gpus[].valid]|add), ([.gpus[].inval]|add), [.gpus[].bus] ' 2>/dev/null)
  
  unit="hs"

  uptime="${temp_data[0]/s/}"
  khs="${temp_data[1]}"
  khs=`echo $khs | sed -E 's/^( *[0-9]+\.[0-9]([0-9]*[1-9])?)0+$/\1/'` #1234.100 -> 1234.1
  hs="${temp_data[2]}"
  temp="${temp_data[3]}"
  fan="${temp_data[4]}"
  acceped="${temp_data[5]}"
  rejected="${temp_data[6]}"
  bus_numbers="${temp_data[7]}"

  version="$CUSTOM_VERSION"
  
  # Example of `$stats` var
  #{ 
  #	"hs": [123, 223.3], //array of hashes
  #	"hs_units": "khs", //Optional: units that are uses for hashes array, "hs", "khs", "mhs", ... Default "khs".   
  #	"temp": [60, 63], //array of miner temps
  #	"fan": [80, 100], //array of miner fans
  #	"uptime": 12313232, //seconds elapsed from miner stats
  #	"ver": "1.2.3.4-beta", //miner version currently run, parsed from it's api or manifest 
  #	"ar": [123, 3], //Optional: acceped, rejected shares 
  #	"algo": "customalgo", //Optional: algo used by miner, should one of the exiting in Hive
  #	"bus_numbers": [0, 1, 12, 13] //Pci buses array in decimal format. E.g. 0a:00.0 is 10
  #}
  
  stats=$(jq -nc --arg khs "$khs" \
                 --argjson hs "$hs" \
                 --arg hs_units "$unit" \
                 --argjson temp "$temp" \
                 --argjson fan "$fan" \
                 --arg acceped "$acceped" \
                 --arg rejected "$rejected" \
                 --arg uptime "$uptime" \
                 --arg ver "$version" \
                 --arg algo "$algo" \
                 --argjson bus_numbers "$bus_numbers" \
                 '{$hs, "hs_units":$hs_units, 
                   $temp, $fan, "ar": [ $acceped|tonumber, $rejected|tonumber], $bus_numbers,
                   "uptime":$uptime|tonumber|floor, $ver, $algo}')

  echo "$stats"
fi
