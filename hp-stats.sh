#!/bin/bash
#Author: Ravil Kadyrbayev | email: e.xnqleonlri@tznvy.pbz
#ZABBIX HP RAID Autodiscovery bash script(v 1.0)
export LC_ALL=""
export LANG="en_US.UTF-8"

HPACUCLI="sudo $(which hpacucli)"

if [[ "$#" -eq 1 ]]; then
    TYPE="${1}"
    CONTROLLERS=`${HPACUCLI} ctrl all show |grep -oE 'Slot [0-9]+' |awk '{print $2}'| xargs echo`
    if [[ ${TYPE} == "contdiscovery" ]]; then
	    if [[ -n ${CONTROLLERS} ]]; then
	      JSON="{ \"data\":["
	      SEP=""
	      for CONTROLLER in ${CONTROLLERS}; do
		      JSON=${JSON}"$SEP{\"{#CONTROLLER}\":\"${CONTROLLER}\"}"
		      SEP=", "
	      done
	      JSON=${JSON}"]}"
	      echo ${JSON}
	    fi
    elif [[ ${TYPE} == "physdiscovery" ]]; then
	    for CONTROLLER in $CONTROLLERS; do
	      DRIVES=`${HPACUCLI} ctrl slot=$CONTROLLER pd all show |grep -w physicaldrive |awk '{print $2}' |xargs echo`
	      if [[ -n ${DRIVES} ]]; then
		      JSON="{ \"data\":["
		      SEP=""
		      for DRIVE in ${DRIVES}; do
		        JSON=${JSON}"$SEP{\"{#CONTROLLER}\":\"${CONTROLLER}\", \"{#PHYSNUM}\":\"${DRIVE}\"}"
		        SEP=", "
		      done
		      JSON=${JSON}"]}"
		      echo ${JSON}
	      fi
	    done
    elif [[ ${TYPE} == "virtdiscovery" ]]; then
	    for CONTROLLER in $CONTROLLERS; do
	      DRIVES=`${HPACUCLI} ctrl slot=$CONTROLLER ld all show |grep -w logicaldrive |awk '{print $2}' |xargs echo`
	      if [[ -n ${DRIVES} ]]; then
		      JSON="{ \"data\":["
		      SEP=""
		      for DRIVE in ${DRIVES}; do
		        JSON=${JSON}"$SEP{\"{#CONTROLLER}\":\"${CONTROLLER}\", \"{#VIRTNUM}\":\"${DRIVE}\"}"
		        SEP=", "
		      done
		      JSON=${JSON}"]}"
		      echo ${JSON}
	      fi
	    done
    fi
    exit 0
elif [[ "$#" -eq 2 ]]; then
    CONTROLLER="${1}"
    METRIC="${2}"
    if [[ $METRIC == "battery" ]]; then
	    ${HPACUCLI} ctrl slot=$CONTROLLER show |grep "Battery/Capacitor Status" |awk '{print $3}'
    elif [[ $METRIC == "cache" ]]; then
	    ${HPACUCLI} ctrl slot=$CONTROLLER show |grep "Cache Status" |awk '{print $3}'
    elif [[ $METRIC == "status" ]]; then
	    ${HPACUCLI} ctrl slot=$CONTROLLER show |grep "Controller Status" |awk '{print $3}'
    fi

elif [[ "$#" -eq 4 ]]; then
    CONTROLLER="${1}"
    TYPE="${2}"
    DRIVE="${3}"
    METRIC="${4}"
    if [[ $METRIC == "status" ]]; then
	    ${HPACUCLI} ctrl slot=$CONTROLLER $TYPE $DRIVE show |grep "  Status" |awk '{print $2}'
    elif [[ $METRIC == "temperature" ]]; then
	    ${HPACUCLI} ctrl slot=$CONTROLLER pd $DRIVE show | grep "Current Temperature"|awk '{print $4}'
    fi
fi
