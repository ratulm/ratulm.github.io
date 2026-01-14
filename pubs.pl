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
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Ratul Mahajan - Publications</title>
  <style>
    * {
      margin: 0;
      padding: 0;
      box-sizing: border-box;
    }
    
    body {
      font-family: -apple-system, BlinkMacSystemFont, \'Segoe UI\', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
      line-height: 1.6;
      color: #333;
      background: #fff;
      padding: 20px;
    }
    
    .container {
      max-width: 900px;
      margin: 0 auto;
      padding: 40px 20px;
    }
    
    h1 {
      font-size: 2.5em;
      font-weight: 300;
      margin-bottom: 30px;
      color: #1a1a1a;
      border-bottom: 2px solid #0066cc;
      padding-bottom: 15px;
    }
    
    h2 {
      font-size: 1.8em;
      font-weight: 400;
      margin: 40px 0 20px 0;
      color: #1a1a1a;
    }
    
    .nav-links {
      margin-bottom: 40px;
      padding: 20px;
      background: #f8f9fa;
      border-radius: 8px;
    }
    
    .nav-links ul {
      list-style: none;
      display: flex;
      flex-wrap: wrap;
      gap: 20px;
    }
    
    .nav-links li:before {
      content: "→";
      margin-right: 8px;
      color: #0066cc;
    }
    
    .nav-links a {
      color: #0066cc;
      text-decoration: none;
      font-weight: 500;
    }
    
    .nav-links a:hover {
      text-decoration: underline;
    }
    
    table {
      width: 100%;
      border-collapse: collapse;
      margin-bottom: 30px;
    }
    
    td {
      padding: 15px 0;
      vertical-align: top;
    }
    
    td:first-child {
      width: 10px;
    }
    
    a {
      color: #0066cc;
      text-decoration: none;
      transition: color 0.2s;
    }
    
    a:hover {
      color: #004499;
      text-decoration: underline;
    }
    
    b {
      font-weight: 600;
      color: #1a1a1a;
    }
    
    .year-header {
      font-size: 1.5em;
      font-weight: 500;
      color: #0066cc;
      margin-top: 40px;
      margin-bottom: 20px;
      padding-bottom: 10px;
      border-bottom: 1px solid #e0e0e0;
    }
    
    .paper-entry {
      margin-bottom: 25px;
      padding-bottom: 25px;
      border-bottom: 1px solid #f0f0f0;
    }
    
    .paper-entry:last-child {
      border-bottom: none;
    }
    
    .paper-title {
      font-size: 1.05em;
      font-weight: 600;
      margin-bottom: 6px;
      line-height: 1.4;
    }
    
    .paper-authors {
      color: #666;
      margin: 4px 0;
    }
    
    .paper-venue {
      color: #888;
      font-style: italic;
      margin: 4px 0;
    }
    
    .paper-note {
      color: #0066cc;
      font-weight: 600;
      margin-top: 6px;
    }
    
    .paper-resource {
      margin-top: 6px;
    }
    
    @media (max-width: 768px) {
      h1 {
        font-size: 2em;
      }
      
      .nav-links ul {
        flex-direction: column;
        gap: 10px;
      }
    }
  </style>
</head>
<body>
  <div class="container">
    <h1>Publications</h1>
';
}


sub PrintFooter() {

    print "
  </div>
</body>
</html>
";

}

sub PrintByTopic()  {

    print "<div class=\"nav-links\">\n<ul>\n";

    for (my $i=0; $i < @topicOrder; $i++) {
    
	next if ($topicOrder[$i] =~ m/selected/ ||
		 $topicOrder[$i] =~ m/ignore/);

	print "<li><a href=\"\#$topicOrder[$i]\">$topics{$topicOrder[$i]}</a></li>\n";

    }

    print "</ul>\n</div>\n";

    for (my $i=0; $i < @topicOrder; $i++) {
    
	next if ($topicOrder[$i] =~ m/selected/ ||
		 $topicOrder[$i] =~ m/ignore/);

	print "<h2 id=\"$topicOrder[$i]\">$topics{$topicOrder[$i]}</h2>\n";
	print '<table>
';

	for (my $paperId=0; $paperId<@allEntries; $paperId++) {

	    if ($allEntries[$paperId]{topics} =~ m/$topicOrder[$i]/) {

		#lets ignore papers marked as ignore
		next if ($allEntries[$paperId]{topics} =~ m/ignore/);
	
		print "<tr><td></td><td class=\"paper-entry\">";
		PrintPaper($paperId);
		print "</td></tr>";
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
	    print "</table>\n" if ($lastPrintedYear != -1);

	    print "<div class=\"year-header\">$year</div>\n";
	    print '<table>
';
	    
	    $lastPrintedYear = $year;
	}

	#lets ignore papers marked as ignore
	##print STDERR $allEntries[$i]{URL};
	next if ($allEntries[$i]{topics} =~ m/ignore/);
	
	print "<tr><td></td><td class=\"paper-entry\">";
	PrintPaper($i);
	print "</td></tr>";
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

    print "<div class=\"paper-title\"><a href=\"$allEntries[$paperId]{URL}\">$title</a></div>\n";
    print "<div class=\"paper-authors\">$author</div>\n";
    print "<div class=\"paper-venue\">$venue, $allEntries[$paperId]{year}</div>\n";

    if (defined $allEntries[$paperId]{note}) {
	print "<div class=\"paper-note\">$allEntries[$paperId]{note}</div>\n";
    }

    if (defined $allEntries[$paperId]{resource}) {
	print "<div class=\"paper-resource\">$allEntries[$paperId]{resource}</div>\n";
    }
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


