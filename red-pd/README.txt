
Requirements:

1. Make sure you have the following binaries in your PATH variable
	1. ns 
	2. gnuplot
	3. gv
	4. awk
	5. grep
	6. sort

2. perl is installed in /usr/bin/perl 

3. csh is installed in /bin/csh

4. If you are running from a remote machine, the DISPLAY variable should be set correctly (for popping up the graphs automatically).

If any of the first 3 requirements are not met, you will have to modify the scripts in the right places.

Instructions for running the simulations are relative to the version of the RED-PD paper at http://www.cs.washington.edu/homes/ratul/red-pd/paper_quals.ps 
The working directory is assumed to be ~ns/tcl/ex/red-pd
The commands shown below assume that all files ending in '.sh' and '.pl' are executable (can be made so using chmod +x <filename>). If that is not the case run 'file.sh' and 'file.pl' using  'csh file.sh' and 'perl file.pl' respectively.

As a result of running the scripts, the graphs will be created as postscript files in the appropriate directories. They will also pop up automatically at the end of simulation.

To run all the simualtions at one go  
	% runall.sh 

Figure 9 and 16 (probability of identification)
	% PIdent/PIdent.sh

Figure 10 
	% allUDP/allUDP.sh

Figure 11
	% mix/mix.sh

Figure 12
	% response/response.sh

Figure 13
	% varying/varying.sh

Figure 14
	% allTCP/allTCP.sh

Figure 15
	% singleVsMulti/singleVsMulti.sh

Figure 16 
	same as Figure 9 (above)

Figure 17
	% testFRp/testFRp.sh

Figure 18
	% testFRp_tcp/testFRp_tcp.sh

Figure 19 and 20
	% web/web.sh

Figure 21 and 22 
	% tfrc/tfrc.sh

Figure 23
	% multi/multi.sh

Figure 24
	% pktsVsBytes/pktsVsBytes.sh

