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


FUSEKI_SPARQL_QUERY_URL="http://127.0.0.1:3030/sp2b/query"
FUSEKI_SPARQL_UPDATE_URL="http://127.0.0.1:3030/sp2b/update"


setup_fuseki() {
    if [ ! -d "$SP2B_ROOT_PATH/fuseki" ]; then
        echo "==== Checking-out and compiling Fuseki source code ..."
        echo "== Start: $(date +"%Y-%m-%d %H:%M:%S")"
        cd $SP2B_ROOT_PATH
        svn co https://svn.apache.org/repos/asf/incubator/jena/Jena2/Fuseki/trunk/ fuseki
        cd $SP2B_ROOT_PATH/fuseki
        mvn package
        echo "== Finish: $(date +"%Y-%m-%d %H:%M:%S")"
    else
        echo "==== [skipped] Checking-out and compiling Fuseki source code ..."
    fi
}


run_fuseki() {
    echo "== Starting Fuseki ..."
    java -server -jar $SP2B_ROOT_PATH/fuseki/target/fuseki-*-SNAPSHOT-sys.jar --update --loc=$SP2B_ROOT_PATH/datasets/tdb-$SP2B_DATASET_SIZE /sp2b &>> $SP2B_ROOT_PATH/results/$SP2B_DATASET_SIZE-fuseki.log &
    sleep 4
    echo "== Done."
}


shutdown_fuseki() {
    PID="`ps -ef | grep fuseki | grep -v grep | awk '{print $2}'`"
    if [[ -n $PID ]] ; then
        echo "== Shutting down Fuseki ..."
        kill $PID
        sleep 1
        echo "== Done."
    else
        echo "== [skipped] Shutting down Fuseki ..."
    fi
}


test_fuseki() {
    shutdown_fuseki

    if [ ! -f "$SP2B_ROOT_PATH/results/$SP2B_DATASET_SIZE-fuseki.txt" ]; then
        run_fuseki
        free_os_caches
        run_sp2b "fuseki" $FUSEKI_SPARQL_QUERY_URL $FUSEKI_SPARQL_UPDATE_URL
        shutdown_fuseki
    else
        echo "==== [skipped] Running SP2B: sut=Fuseki, size=$SP2B_DATASET_SIZE ..."
    fi

}


