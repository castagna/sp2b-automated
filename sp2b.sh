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


SP2B_QUERY_FILES=( q1 q2 q3a q3b q3c q4 q5a q5b q6 q7 q8 q9 q10 q11 q12a q12b q12c ) 


setup_sp2b() {
    if [ ! -d "$SP2B_ROOT_PATH/sp2b" ]; then
        echo "==== Downloading SP2B ..."
        echo "== Start: $(date +"%Y-%m-%d %H:%M:%S")"
        cd $SP2B_ROOT_PATH
        wget http://dbis.informatik.uni-freiburg.de/content/projects/SP2B/docs/sp2b-v1_01-full.tar.gz
        tar xvfz sp2b-v1_01-full.tar.gz
        rm sp2b-v1_01-full.tar.gz
        echo "== Finish: $(date +"%Y-%m-%d %H:%M:%S")"
    else
        echo "==== [skipped] Downloading SP2B ..."
    fi
}


generate_sp2b_dataset() {
    if [ ! -f "$SP2B_ROOT_PATH/datasets/sp2b-$SP2B_DATASET_SIZE.n3" ]; then
        echo "==== Generating dataset: size=$SP2B_DATASET_SIZE ..."
        echo "== Start: $(date +"%Y-%m-%d %H:%M:%S")"
        if [ ! -d "$SP2B_ROOT_PATH/datasets" ]; then
            mkdir $SP2B_ROOT_PATH/datasets
        fi
        cd $SP2B_ROOT_PATH/sp2b/bin
        ./sp2b_gen -t $SP2B_DATASET_SIZE $SP2B_ROOT_PATH/datasets/sp2b-$SP2B_DATASET_SIZE.n3
        echo "== Finish: $(date +"%Y-%m-%d %H:%M:%S")"
    else
        echo "==== [skipped] Generating dataset: size=$SP2B_DATASET_SIZE ..."
    fi
}


run_sp2b() {
    SYSTEM_UNDER_TEST=`echo $1 | tr '[:upper:]' '[:lower:]'`
    SPARQL_QUERY_URL=$2
    SPARQL_UPDATE_URL=$3

    RESULT_FILENAME=sp2b-$SP2B_DATASET_SIZE-$SYSTEM_UNDER_TEST
    if [ ! -f "$SP2B_ROOT_PATH/results/$RESULT_FILENAME.txt" ]; then
        echo "==== Running SP2B: sut=$SYSTEM_UNDER_TEST, size=$SP2B_DATASET_SIZE ..."
        echo "== Start: $(date +"%Y-%m-%d %H:%M:%S")"
        cd $SP2B_ROOT_PATH/sp2b/queries
        for SP2B_QUERY_FILE in ${SP2B_QUERY_FILES[@]} 
        do
            QUERY=`cat $SP2B_QUERY_FILE.sparql`
            echo -e "\n$SP2B_QUERY_FILE.sparql" >> $SP2B_ROOT_PATH/results/$RESULT_FILENAME.txt
            for i in `seq 1 $NUM_QUERY_RUNS`
            do
                START=$(date +%s.%N)
                /usr/bin/time -f "%E real, %U user, %S sys" -a --output=$SP2B_ROOT_PATH/results/$RESULT_FILENAME.txt curl $SPARQL_QUERY_URL --data-urlencode "query=$QUERY" > /dev/null
                END=$(date +%s.%N)
                DIFF=$(echo "($END - $START) * 1000" | bc)
                echo "$DIFF ms" >> $SP2B_ROOT_PATH/results/$RESULT_FILENAME.txt
            done
        done
        echo "== Finish: $(date +"%Y-%m-%d %H:%M:%S")"
    fi
}


run_sp2b_tdb() {
    SYSTEM_UNDER_TEST=`echo $1 | tr '[:upper:]' '[:lower:]'`

    RESULT_FILENAME=sp2b-$SP2B_DATASET_SIZE-$SYSTEM_UNDER_TEST
    if [ ! -f "$SP2B_ROOT_PATH/results/$RESULT_FILENAME.txt" ]; then
        echo "==== Running SP2B: sut=$SYSTEM_UNDER_TEST, size=$SP2B_DATASET_SIZE ..."
        echo "== Start: $(date +"%Y-%m-%d %H:%M:%S")"
        OLD_TDBROOT=$TDBROOT
        export TDBROOT=$SP2B_ROOT_PATH/tdb
        OLD_PATH=$PATH
        export PATH=$SP2B_ROOT_PATH/tdb/bin:$SP2B_ROOT_PATH/tdb/bin2:$PATH
        cd $SP2B_ROOT_PATH/sp2b/queries
        for SP2B_QUERY_FILE in ${SP2B_QUERY_FILES[@]} 
        do
            echo -e "\n$SP2B_QUERY_FILE.sparql" >> $SP2B_ROOT_PATH/results/$RESULT_FILENAME.txt
            tdbquery --time --results=count --repeat=$NUM_WARMUP_QUERY_RUNS,$NUM_QUERY_RUNS --quiet --loc $SP2B_ROOT_PATH/datasets/tdb-$SP2B_DATASET_SIZE/ --query $SP2B_ROOT_PATH/sp2b/queries/$SP2B_QUERY_FILE.sparql >> $SP2B_ROOT_PATH/results/$RESULT_FILENAME.txt
        done
        export PATH=$OLD_PATH
        export TDBROOT=$OLD_TDBROOT
        echo "== Finish: $(date +"%Y-%m-%d %H:%M:%S")"
    fi
}


run_sp2b_stardog() {
    SYSTEM_UNDER_TEST=`echo $1 | tr '[:upper:]' '[:lower:]'`

    RESULT_FILENAME=sp2b-$SP2B_DATASET_SIZE-$SYSTEM_UNDER_TEST
    if [ ! -f "$SP2B_ROOT_PATH/results/$RESULT_FILENAME.txt" ]; then
        echo "==== Running SP2B: sut=$SYSTEM_UNDER_TEST, size=$SP2B_DATASET_SIZE ..."
        echo "== Start: $(date +"%Y-%m-%d %H:%M:%S")"
        STARDOG_HOME=$SP2B_ROOT_PATH/datasets/stardog-$SP2B_DATASET_SIZE
        cd $SP2B_ROOT_PATH/sp2b/queries
        for SP2B_QUERY_FILE in ${SP2B_QUERY_FILES[@]} 
        do
            QUERY=`tr '\n' ' ' < $SP2B_QUERY_FILE.sparql`
            echo -e "\n$SP2B_QUERY_FILE.sparql" >> $SP2B_ROOT_PATH/results/$RESULT_FILENAME.txt
            for i in `seq 1 $NUM_QUERY_RUNS`
            do
                START=$(date +%s.%N)
                /usr/bin/time -f "%E real, %U user, %S sys" -a --output=$SP2B_ROOT_PATH/results/$RESULT_FILENAME.txt $STARDOG_INSTALLATION/stardog query --home $STARDOG_HOME -c "native://stardog_$SP2B_DATASET_SIZE" -q "$QUERY" > /dev/null
                END=$(date +%s.%N)
                DIFF=$(echo "($END - $START) * 1000" | bc)
                echo "$DIFF ms" >> $SP2B_ROOT_PATH/results/$RESULT_FILENAME.txt
            done
        done
        echo "== Finish: $(date +"%Y-%m-%d %H:%M:%S")"
    fi
}


run_sp2b_stardog_http() {
    SYSTEM_UNDER_TEST=`echo $1 | tr '[:upper:]' '[:lower:]'`
    SPARQL_QUERY_URL=$2

    RESULT_FILENAME=sp2b-$SP2B_DATASET_SIZE-$SYSTEM_UNDER_TEST
    if [ ! -f "$SP2B_ROOT_PATH/results/$RESULT_FILENAME.txt" ]; then
        echo "==== Running SP2B: sut=$SYSTEM_UNDER_TEST, size=$SP2B_DATASET_SIZE ..."
        echo "== Start: $(date +"%Y-%m-%d %H:%M:%S")"
        cd $SP2B_ROOT_PATH/sp2b/queries
        for SP2B_QUERY_FILE in ${SP2B_QUERY_FILES[@]} 
        do
            QUERY=`cat $SP2B_QUERY_FILE.sparql`
            echo -e "\n$SP2B_QUERY_FILE.sparql" >> $SP2B_ROOT_PATH/results/$RESULT_FILENAME.txt
            for i in `seq 1 $NUM_WARMUP_QUERY_RUNS`
            do
                curl --basic -u"anonymous:anonymous" --get $SPARQL_QUERY_URL --data-urlencode "query=$QUERY" > /dev/null
            done
            for i in `seq 1 $NUM_QUERY_RUNS`
            do
                START=$(date +%s.%N)
                /usr/bin/time -f "%E real, %U user, %S sys" -a --output=$SP2B_ROOT_PATH/results/$RESULT_FILENAME.txt curl --basic -u"anonymous:anonymous" --get $SPARQL_QUERY_URL --data-urlencode "query=$QUERY" > /dev/null
                END=$(date +%s.%N)
                DIFF=$(echo "($END - $START) * 1000" | bc)
                echo "$DIFF ms" >> $SP2B_ROOT_PATH/results/$RESULT_FILENAME.txt
            done
        done
        echo "== Finish: $(date +"%Y-%m-%d %H:%M:%S")"
    fi
}
