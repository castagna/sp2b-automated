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


TDB_LOADER=tdbloader2

load_tdb() {
    if [ ! -d "$SP2B_ROOT_PATH/datasets/tdb-$SP2B_DATASET_SIZE" ]; then
        echo "==== Loading data in TDB: scale=$SP2B_DATASET_SIZE ..."
        echo "== Start: $(date +"%Y-%m-%d %H:%M:%S")"
        free_os_caches
        OLD_TDBROOT=$TDBROOT
        export TDBROOT=$SP2B_ROOT_PATH/tdb
        OLD_PATH=$PATH
        export PATH=$SP2B_ROOT_PATH/tdb/bin:$SP2B_ROOT_PATH/tdb/bin2:$PATH
        mkdir $SP2B_ROOT_PATH/datasets/tdb-$SP2B_DATASET_SIZE
        if [ ! -d "$SP2B_ROOT_PATH/results" ]; then
            mkdir $SP2B_ROOT_PATH/results
        fi
        $TDB_LOADER --loc $SP2B_ROOT_PATH/datasets/tdb-$SP2B_DATASET_SIZE $SP2B_ROOT_PATH/datasets/sp2b-$SP2B_DATASET_SIZE.n3 > $SP2B_ROOT_PATH/results/tdb-$SP2B_DATASET_SIZE-tdbload.txt
        tdbstats --loc $SP2B_ROOT_PATH/datasets/tdb-$SP2B_DATASET_SIZE > $SP2B_ROOT_PATH/datasets/tdb-$SP2B_DATASET_SIZE/stats.opt
        ls -la $SP2B_ROOT_PATH/datasets/tdb-$SP2B_DATASET_SIZE > $SP2B_ROOT_PATH/results/tdb-$SP2B_DATASET_SIZE-size.txt
        du -sh $SP2B_ROOT_PATH/datasets/tdb-$SP2B_DATASET_SIZE >> $SP2B_ROOT_PATH/results/tdb-$SP2B_DATASET_SIZE-size.txt
        export PATH=$OLD_PATH
        export TDBROOT=$OLD_TDBROOT
        echo "== Finish: $(date +"%Y-%m-%d %H:%M:%S")"
    else
        echo "==== [skipped] Loading data in TDB: scale=$SP2B_DATASET_SIZE ..."
    fi
}


setup_tdb() {
    if [ ! -d "$SP2B_ROOT_PATH/tdb" ]; then
        echo "==== Checking-out and compiling TDB source code ..."
        echo "== Start: $(date +"%Y-%m-%d %H:%M:%S")"
        cd $SP2B_ROOT_PATH
        svn co https://svn.apache.org/repos/asf/incubator/jena/Jena2/ARQ/trunk/ arq
        cd $SP2B_ROOT_PATH/arq
        mvn package
        cd $SP2B_ROOT_PATH
        svn co https://svn.apache.org/repos/asf/incubator/jena/Jena2/TDB/trunk/ tdb
        cd $SP2B_ROOT_PATH/tdb
        # to make sure we use the latest ARQ SNAPSHOT
        rm $SP2B_ROOT_PATH/tdb/lib/arq-*
        rm $SP2B_ROOT_PATH/tdb/lib-src/arq-*
        cp $SP2B_ROOT_PATH/arq/target/arq-*-SNAPSHOT.jar $SP2B_ROOT_PATH/tdb/lib/
        cp $SP2B_ROOT_PATH/arq/target/arq-*-SNAPSHOT-sources.jar $SP2B_ROOT_PATH/tdb/lib-src/
        mvn package
        echo "== Finish: $(date +"%Y-%m-%d %H:%M:%S")"
    else
        echo "==== [skipped] Checking-out and compiling TDB source code ..."
    fi
}


test_tdb() {
    if [ ! -f "$SP2B_ROOT_PATH/results/sp2b-$SP2B_DATASET_SIZE-tdb.txt" ]; then
        free_os_caches
        run_sp2b_tdb "tdb"
    else
        echo "==== [skipped] Running SP2B: sut=TDB, size=$SP2B_DATASET_SIZE ..."
    fi
}


