
### About Shoreline
The Shoreline platform provides real-time monitoring, alerting, and incident automation for cloud operations. Use Shoreline to detect, debug, and automate repairs across your entire fleet in seconds with just a few lines of code.

Shoreline Agents are efficient and non-intrusive processes running in the background of all your monitored hosts. Agents act as the secure link between Shoreline and your environment's Resources, providing real-time monitoring and metric collection across your fleet. Agents can execute actions on your behalf -- everything from simple Linux commands to full remediation playbooks -- running simultaneously across all the targeted Resources.

Since Agents are distributed throughout your fleet and monitor your Resources in real time, when an issue occurs Shoreline automatically alerts your team before your operators notice something is wrong. Plus, when you're ready for it, Shoreline can automatically resolve these issues using Alarms, Actions, Bots, and other Shoreline tools that you configure. These objects work in tandem to monitor your fleet and dispatch the appropriate response if something goes wrong -- you can even receive notifications via the fully-customizable Slack integration.

Shoreline Notebooks let you convert your static runbooks into interactive, annotated, sharable web-based documents. Through a combination of Markdown-based notes and Shoreline's expressive Op language, you have one-click access to real-time, per-second debug data and powerful, fleetwide repair commands.

### What are Shoreline Op Packs?
Shoreline Op Packs are open-source collections of Terraform configurations and supporting scripts that use the Shoreline Terraform Provider and the Shoreline Platform to create turnkey incident automations for common operational issues. Each Op Pack comes with smart defaults and works out of the box with minimal setup, while also providing you and your team with the flexibility to customize, automate, codify, and commit your own Op Pack configurations.

# "Host Memory is underutilized incident"
---

This incident type refers to a situation where the host memory of a system is not being fully utilized and may be causing performance issues. It may trigger when the memory load is below the expected level for a certain period of time. The incident may require investigation to determine the root cause and may involve reducing the amount of memory or other memory management strategies to optimize system performance.

### Parameters
```shell
export CONFIGURED_AMOUNT_OF_MEMORY="PLACEHOLDER"

export HOST_VM_NAME="PLACEHOLDER"

export DECREASED_MEMORY_SIZE="PLACEHOLDER"
```

## Debug

### 1. Check the memory usage of the affected host
```shell
free -m
```

### 2. Check the current CPU load
```shell
top
```

### 6. Check the system load average
```shell
uptime
```

### 3. List all running processes and their memory usage
```shell
ps -aux --sort=-%mem | head
```

### 4. Check the amount of available disk space
```shell
df -h
```

### 5. Check the system logs for any relevant error messages
```shell
dmesg | tail
```

### 7. List all running Docker containers and their memory usage
```shell
docker stats $(docker ps --format={{.Names}})
```

### 8. Check the system swap usage
```shell
swapon -s
```

### 9. Check the system kernel version
```shell
uname -r
```

### 10. List all installed packages and their versions
```shell
dpkg -l
```

### The server may be overprovisioned with more memory than required for the workload it is running.
```shell


#!/bin/bash



# Get the total amount of memory installed on the system

total_memory=$(free -m | awk '/^Mem:/{print $2}')



# Get the amount of memory currently in use

used_memory=$(free -m | awk '/^Mem:/{print $3}')



# Get the percentage of memory that is currently in use

memory_percent=$(echo "scale=2; $used_memory / $total_memory * 100" | bc)



# Get the amount of memory that is free and available for use

available_memory=$(free -m | awk '/^Mem:/{print $4}')



# Compare the amount of available memory to the configured amount of memory

configured_memory=${CONFIGURED_AMOUNT_OF_MEMORY}

if [ $available_memory -gt $configured_memory ]; then

    echo "The server may be overprovisioned with more memory than required for the workload it is running."

else

    echo "The available memory is within the configured amount, so this is likely not the issue."

fi



# Output the current memory usage information for further analysis

echo "Total memory: $total_memory MB"

echo "Used memory: $used_memory MB ($memory_percent%)"

echo "Available memory: $available_memory MB"


```

## Repair

### Decrease memory allocation: Allocate less memory to the host vm to ensure that it does not have too much unused memory.
```shell
bash

#!/bin/bash



# Define variables

HOST_VM_NAME=${HOST_VM_NAME}

DECREASED_MEMORY_SIZE=${DECREASED_MEMORY_SIZE}



# Check if the host vm exists

if ! virsh list --name --all | grep -q "\${HOST_VM_NAME_}"; then

  echo "Error: Host VM $HOST_VM_NAME does not exist"

  exit 1

fi



# Check if the specified memory size is valid

if ! [[ $DECREASED_MEMORY_SIZE =~ ^[0-9]+$ ]]; then

  echo "Error: Invalid memory size $DECREASED_MEMORY_SIZE"

  exit 1

fi



# Stop the host vm

virsh shutdown $HOST_VM_NAME



# Decrease memory allocation for host vm

virsh setmem $HOST_VM_NAME $DECREASED_MEMORY_SIZE --config



# Start the host vm

virsh start $HOST_VM_NAME



# Verify that the memory allocation has been decreased

virsh dommemstat $HOST_VM_NAME | grep actual


```