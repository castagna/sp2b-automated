SP²Bench SPARQL Automated
-------------------------

SP²Bench SPARQL (SP2B) is a benchmark for comparing performances of an RDF 
store across different architectures or for comparing different RDF stores.

The aim of this project is to make as easy as possible for people to run the 
SP²Bench SPARQL with TDB and Fuseki [1]. Other RDF stores might be added in 
future, since comparison of different systems using same hardware is more
interesting than results for a single system.

You can simply run the bash script typing:

  ./sp2b.sh 

You need bash, Java, Ant, Maven, SVN, wget, etc., and I am not going to explain 
how to install/configure those. The script downloads all the necessary software 
pieces, it sets them up, it uses the SP2B to generate a test dataset and it 
runs the benchmark for you against Fuseki/TDB.
Once finished, you can find the results in the /tmp/sp2b/results/ directory.

I am not a bash "guru", I warned you! You can insult me or send me suggestion
how to improve the scripts. Suggestions are more welcome than insults. ;-)


Have fun with the SP2B and TDB/Fuseki!


                                                              -- Paolo Castagna


 [1] http://openjena.org/wiki/Fuseki

