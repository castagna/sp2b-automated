#!/bin/bash

##
# Copyright © 2011 Talis Systems Ltd.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
##

ROOT_PATH="$( cd -P "$( dirname "$0" )" && pwd )"
SP2B_ROOT_PATH=/tmp/sp2b
NUM_WARMUP_QUERY_RUNS=1
NUM_QUERY_RUNS=3

STARDOG_INSTALLATION=/opt/stardog

source common.sh
source sp2b.sh
source tdb.sh
#source fuseki.sh
#source stardog.sh

setup_tdb
#setup_sp2b
#setup_fuseki

#SP2B_DATASET_SIZES=( 10000 50000 250000 1000000 5000000 25000000 )
SP2B_DATASET_SIZES=( 10000 20000 )

for SP2B_DATASET_SIZE in ${SP2B_DATASET_SIZES[@]} 
do
    generate_sp2b_dataset
#    load_stardog
#    test_stardog_http
    load_tdb
    test_tdb
#    test_fuseki
done

echo "==== Results:"
$ROOT_PATH/report.py $SP2B_ROOT_PATH/results/
