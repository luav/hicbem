#!/bin/sh
#
# \description  Starts benchmarking from the docker container environment
#
# The benchmarking is started under the current user on the current host
# directory, which is bound to the docker container directory.
# The specified arguments are passed to the benchmarking being run in the container.
#
# \author Artem V L <luart@ya.ru>

# Notes:
# - $@  - are the input arguments passed to the benchmark started from the container
# - $UID or `id -u $USER` - user id of the current user, otherwise 'root' is used.
# $UID might not be defined in "sh"

echo "Starting docker from \"`pwd`\" under user \"$USER\" with the benchmark arguments: $@"
WORK_DIR=/opt/pycabem  # Working directory of the benchmark
# Notes:
# - quoted $@ is required to retain internal quotation inside the arguments
# - python3 is used to run the benchmark instead of pypy to reduce the number of
# dependencies, because otherwise Python is also required to install the psutil
# via pip on pypy
# Bind Docker :8080 to the host :80 for tcp. To bind with specific host IP: -p IP:8080:80/tcp
# -rm is used to automaticaly clean up the executed container and remove the virtual file system on exit
# docker run -it -u `id -u $USER` -w ${WORK_DIR} -v `pwd`:${WORK_DIR} --entrypoint python3 luaxi/pycabem:env-U16.04-v2.0 ./benchmark.py "$@"
docker run --rm -it -p 8080:8080/tcp -u `id -u $USER` -w ${WORK_DIR} -v `pwd`:${WORK_DIR} --entrypoint python3 luaxi/pycabem:v3.0.0a-U16.04 ./benchmark.py "$@"
# Or to open "bash" shell in the benchmarking directory:
# $ docker run -it -u `id -u $USER` -w ${WORK_DIR} -v `pwd`:${WORK_DIR} --entrypoint bash luaxi/pycabem:env-U16.04-v2.0

# Examples:
# $ ./benchmark_docker.sh -a="LouvainIg Randcommuns" -i="syntnets/networks/*/" -i=./realnets -r -th=42 1>>./results/bench.log 2>>./results/bench.err
# $ ./benchmark_docker.sh -a="LouvainIg Scp Randcommuns Pscan" -i%2=./realnets -r -th=42 1>> ./results/bench.log 2>> ./results/bench.err

# Note: to redirect host:80 to :8080, where the benchmark WebUI is run:
# # iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 8080
# To check redirection:
# # iptables -t nat --line-numbers -n -L
# To remove redirection:
# iptables -t nat -D PREROUTING 2

