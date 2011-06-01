#!/usr/bin/env python

import sys
import os


sizes = []
systems_under_test = []
queries = []
times = {}

path = sys.argv[1]

flist = os.listdir(path)
sortedflist = sorted(flist)
for fname in sortedflist:
    if ( fname.startswith ("sp2b-") and fname.endswith (".txt") ):
        tokens = fname[:-4].rsplit("-")
        if ( not int(tokens[1]) in sizes ): sizes.append(int(tokens[1]))
        if ( not tokens[2] in systems_under_test ): systems_under_test.append(tokens[2])

sizes = sorted(sizes)
systems_under_test = sorted(systems_under_test)


right_margin = 12
width = 5

for size in sizes:
    for system_under_test in systems_under_test:
        filename = sys.argv[1] + "sp2b-" + str(size) + "-" + system_under_test + ".txt"
        try:
            f = open(filename, 'r')
            first = True
            for line in f:
                if line.endswith (".sparql\n"): 
                    if ( not first ):
                        key = system_under_test + "|" + str(size) + "|" + query
                        times[key] = time / count
                    query = line[:-8]
                    if ( not query in queries ): queries.append(query)
                    count = 0
                    time = 0
                    first = False
                if ( system_under_test == "tdb" ):
                    if line.startswith ("Time: "): 
                        count += 1
                        time += float(line[5:-5]) * 1000
                else:
                    if line.endswith (" ms\n"): 
                        count += 1
                        time += float(line[:-4])
            key = system_under_test + "|" + str(size) + "|" + query
            times[key] = time / count
            f.close()
        except: 
            pass

for system_under_test in systems_under_test:
    print ("{sut:>{right_margin}}".format(sut=system_under_test, right_margin=right_margin)),
    for query in queries:
        print ("{query:>{width}}".format(query=query, width=width)),
    print ""
    for size in sizes:
        print ("{size:>{right_margin}}".format(size=str(size), right_margin=right_margin)),
        for query in queries:
            key = system_under_test + "|" + str(size) + "|" + query
            if ( key in times ):
                print ("{time:>{width}.0f}".format(time=times[key], width=width)),
            else:
                print ("{time:>{width}}".format(time="-", width=width)),
        print ""
    print ""

