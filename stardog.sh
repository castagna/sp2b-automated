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

load_stardog() {
    STARDOG_HOME=$SP2B_ROOT_PATH/datasets/stardog-$SP2B_DATASET_SIZE
    if [ ! -d "$STARDOG_HOME" ]; then
        echo "==== Loading data in Stardog: scale=$SP2B_DATASET_SIZE ..."
        echo "== Start: $(date +"%Y-%m-%d %H:%M:%S")"
        free_os_caches
        mkdir $STARDOG_HOME
        if [ ! -d "$SP2B_ROOT_PATH/results" ]; then
            mkdir $SP2B_ROOT_PATH/results
        fi
        $STARDOG_INSTALLATION/stardog create --home $STARDOG_HOME --name stardog_$SP2B_DATASET_SIZE --type D $SP2B_ROOT_PATH/datasets/sp2b-$SP2B_DATASET_SIZE.n3 > $SP2B_ROOT_PATH/results/stardog-$SP2B_DATASET_SIZE-load.txt
        ls -la $STARDOG_HOME > $SP2B_ROOT_PATH/results/stardog-$SP2B_DATASET_SIZE-size.txt
        du -sh $STARDOG_HOME >> $SP2B_ROOT_PATH/results/stardog-$SP2B_DATASET_SIZE-size.txt
        echo "== Finish: $(date +"%Y-%m-%d %H:%M:%S")"
    else
        echo "==== [skipped] Loading data in Stardog: size=$SP2B_DATASET_SIZE ..."
    fi
}


run_stardog() {
    echo "== Starting Stardog ..."
    export STARDOG_HOME=$SP2B_ROOT_PATH/datasets/stardog-$SP2B_DATASET_SIZE
    java -server -jar $STARDOG_INSTALLATION/lib/stardog-server-0.5.3.jar 8989 &>> $SP2B_ROOT_PATH/results/$SP2B_DATASET_SIZE-stardog.log &
    sleep 4
    echo "== Done."
}


shutdown_stardog() {
    PID="`ps -ef | grep stardog | grep java | grep -v grep | awk '{print $2}'`"
    if [[ -n $PID ]] ; then
        echo "== Shutting down Stardog ..."
        kill $PID
        sleep 1
        echo "== Done."
    else
        echo "== [skipped] Shutting down Stardog ..."
    fi
}


test_stardog_http() {
    if [ ! -f "$SP2B_ROOT_PATH/results/sp2b-$SP2B_DATASET_SIZE-stardog_http.txt" ]; then
        run_stardog
        free_os_caches
        STARDOG_SPARQL_QUERY_URL="http://127.0.0.1:8989/stardog_$SP2B_DATASET_SIZE/query"
        run_sp2b_stardog_http "stardog_http" $STARDOG_SPARQL_QUERY_URL
        shutdown_stardog
    else
        echo "==== [skipped] Running SP2B: sut=Stardog HTTP, size=$SP2B_DATASET_SIZE ..."
    fi
}


