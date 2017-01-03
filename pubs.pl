#!/usr/bin/perl -w

use strict;


###########################################
use Getopt::Long;

my ($HELP, $VERBOSE) = (   "",     0);
my ($MODE) = ("time");

GetOptions ("help"         => \$HELP,
            "verbose!"     => \$VERBOSE,
	    "mode=s"       => \$MODE,
           );
if ($HELP or @ARGV == 0) {usage(); exit(0);}


sub usage {
  print STDERR "\n usage: $0 [options] <list of files>
  --help: this message
  --verbose: debug mode [off]
  --mode <mode>: one of {time, topic, selected, cv} 
\n";
}

my @files = @ARGV;
##################################

my @topicOrder;
my %topics; 

my $count=-1;

my @allEntries;


#############################


sub PrintHeader() {

    print '
<html>
<head>
  <title>ratul\'s publications</title>
</head>
<body bgcolor="#ffffff">
';
}


sub PrintFooter() {

    print "
</body>
</html>
";

}

sub PrintByTopic()  {

    print "<ul>\n";

    for (my $i=0; $i < @topicOrder; $i++) {
    
	next if ($topicOrder[$i] =~ m/selected/ ||
		 $topicOrder[$i] =~ m/ignore/);

	print "<li><a href=\"\#$topicOrder[$i]\">$topics{$topicOrder[$i]}</a>\n";

    }

    print "</ul>\n";

    for (my $i=0; $i < @topicOrder; $i++) {
    
	next if ($topicOrder[$i] =~ m/selected/ ||
		 $topicOrder[$i] =~ m/ignore/);

	print "<p><a name=$topicOrder[$i]></a>\n
               <b>$topics{$topicOrder[$i]}</b>\n";
	print '
<table style="width: 100%;" cellpadding="2" cellspacing="2">
<tr><td width=10px><td></tr>
';

	for (my $paperId=0; $paperId<@allEntries; $paperId++) {

	    if ($allEntries[$paperId]{topics} =~ m/$topicOrder[$i]/) {
		print "<tr><td><td>";

		#lets ignore papers marked as ignore
		next if ($allEntries[$paperId]{topics} =~ m/ignore/);
	
		PrintPaper($paperId);
	    }	
	}

	print "</table>\n";
    }
}

sub PrintByTime() {

    my $lastPrintedYear = -1;
    
    for (my $i=0; $i<@allEntries; $i++) {
	my $year = $allEntries[$i]{year};
	if ($year != $lastPrintedYear) {

	    #end the previous table
	    print "</table>\n";

	    print "<p><b>$year</b>\n";
	    print '
<table style="width: 100%;" cellpadding="2" cellspacing="2">
<tr><td width=10px><td></tr>
';
	    
	    $lastPrintedYear = $year;
	}

	#lets ignore papers marked as ignore
	##print STDERR $allEntries[$i]{URL};
	next if ($allEntries[$i]{topics} =~ m/ignore/);
	
	print "<tr><td><td>";
	PrintPaper($i);
    }
    
}


sub PrintSelected() {
    
    die "print selected not yet implemented\n";
}

sub PrintCv()  {

for (my $i=0; $i < @topicOrder; $i++) {
    
	next if ($topicOrder[$i] =~ m/selected/ ||
		 $topicOrder[$i] =~ m/ignore/);

	print "\\item \{\\bf $topics{$topicOrder[$i]}\}\n";
	print "\\begin\{innerlist\}\n";

	for (my $paperId=0; $paperId<@allEntries; $paperId++) {

		if ($allEntries[$paperId]{topics} =~ m/$topicOrder[$i]/) {

			#lets ignore papers marked as ignore or 
			next if ($allEntries[$paperId]{topics} =~ m/ignore/);
			#lets ignore papers of type misc
			next if ($allEntries[$paperId]{paperType} =~ m/misc/);

			my $author = $allEntries[$paperId]{author};
	        $author =~ s/ and /, /g;

	        my $venue = "unknown";
	        if (defined($allEntries[$paperId]{booktitle})) {
		        $venue = $allEntries[$paperId]{booktitle};
	        }
	        elsif (defined($allEntries[$paperId]{journal})) {
		        $venue = $allEntries[$paperId]{journal};
	        }
	        elsif (defined($allEntries[$paperId]{howpublished})) {
		        $venue = $allEntries[$paperId]{howpublished};
	        }
	        else {
		       die "Could not find venue for $allEntries[$paperId]{title}\n";
	        }

	        my $title = $allEntries[$paperId]{title};
	        $title =~ s/(\{|\})//g;

	        print "\\item\n";

	        if (defined $allEntries[$paperId]{impact}) {
	        	print "\\hspace{-0.15in} * ";
	        }

	        print "    $author,\n";
	        print "    \`\`$title,\"\n";
	        print "     \{\\em $venue,\}\n";

	        if ($allEntries[$paperId]{paperType} =~ m/article/) {
	        	print "    $allEntries[$paperId]{volume}($allEntries[$paperId]{number},\n";
	        }

	        print "    $allEntries[$paperId]{month} $allEntries[$paperId]{year}.\n";

	        if (defined $allEntries[$paperId]{acceptancerate}) {
		      print "    ($allEntries[$paperId]{acceptancerate}\\\% acceptance rate)\n";
	        }	

	        if (defined $allEntries[$paperId]{note}) {
		      print "    \{\\bf $allEntries[$paperId]{note}\}\n";
	        }	

		}
    }
    print "\\end\{innerlist\}\n";
}
}

sub PrintPaper() {
    my ($paperId) = @_;

    my $author = $allEntries[$paperId]{author};
    $author =~ s/ and /, /g;

    my $venue = "unknown";
    if (defined($allEntries[$paperId]{booktitle})) {
	$venue = $allEntries[$paperId]{booktitle};
    }
    elsif (defined($allEntries[$paperId]{journal})) {
	$venue = $allEntries[$paperId]{journal};
    }
    elsif (defined($allEntries[$paperId]{howpublished})) {
	$venue = $allEntries[$paperId]{howpublished};
    }
    else {
	die "Could not find venue for $allEntries[$paperId]{title}\n";
    }

    my $title = $allEntries[$paperId]{title};
    $title =~ s/(\{|\})//g;

    print "
<a href=$allEntries[$paperId]{URL}><b>$title</b></a><br>
$author<br>
$venue, $allEntries[$paperId]{year}<br>
";

    if (defined $allEntries[$paperId]{note}) {
	print "<b>$allEntries[$paperId]{note}</b><br>";
    }

    if (defined $allEntries[$paperId]{resource}) {
	print "$allEntries[$paperId]{resource}<br>";
    }

    print "<br>\n";
}


################ main #############

foreach my $file (@files) {
    
    open (my $F, $file) or die;

    while (<$F>) {

	#ignore comments and empty lines
	if (m/^\@comment/ || 
	    m/^\s*$/) {
	
	}
	#topic
	elsif (m/^([a-z]+)\s+:: (.+)$/) {
	    my ($topicKey, $topic) = ($1, $2);
	    $topics{$topicKey} = $topic;
	    push @topicOrder, $topicKey;

	}
    #start of a new entry
    elsif (m/^@([a-z]+)\{(.+)\,/) {
    	my ($paperType, $paperKey) = ($1, $2);    	
        $count++;
        $allEntries[$count]{paperType}=$paperType;
        $allEntries[$count]{paperKey}=$paperKey;
    }
	elsif (m/\s+([a-zA-Z]+)=\{(.+)\}/) {
	    my ($key, $value) = ($1, $2);

	    if (defined($allEntries[$count]) && 
		    defined($allEntries[$count]{$key})) {		
   		   die "duplicate $count or $count/$key";
	    }
	    
	    $allEntries[$count]{$key} = $value;
	}
    }
}


if ($MODE eq "time") {
    PrintHeader();
    PrintByTime();
    PrintFooter();
}
elsif ($MODE eq "topic") {
    PrintHeader();
    PrintByTopic();
    PrintFooter();
}
elsif ($MODE eq "selected") {
    PrintHeader();
    PrintSelected();
    PrintFooter();
}
elsif ($MODE eq "cv") {
	PrintCv();
}
else {
    die "unknown mode: $MODE\n";
}


