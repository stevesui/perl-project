#!/usr/bin/perl

#use strict;
#use warnings;

import IO;

######################
#function definitions#

#Open Tomcat access log and generate separate file for each individual API.
sub genAPIFile {
  
 #  @param = @_;
 #  print "Inside sub ... \$\1 = $_[0]\n";
 #  print "Inside sub ... param = @param\n";
   
   my $MYAPI = $_[0];
 #print "Global file name = $LOGFILE\n";

  #open the tomcat access log file for reading.
  open INPUTFILE, "<","$LOGFILE" or die "cannot open main access log $LOGFILE!";
  
  #create each individual API-named output file for witing.
  open OUTPUTFILE, ">", "./logs/$_[0].txt" or die "cannot open to generate logfile $_[0].txt!";
  
  #loop access file to find match of API pattern
  while (<INPUTFILE>) {
        chomp;
        /.*\/contacts\/v1\/$MYAPI.*/ || next;
        #/$MYAPI/ || next;
        print OUTPUTFILE  "$_\n";
  }
  
  close INPUTFILE;  
  close OUTPUTFILE;
}

##Read all files in logs directory and process each individual API file to get TPS info
sub processAPIFile {

     my $logdir = "./logs";
     opendir(DIR, $logdir) or die $!;
     while ( my $file = readdir(DIR)) {
          next unless (-f "$logdir/$file");
          print "File name === $file\n";
          calculateTPS($logdir. "/".$file);
     }
} 

##Calculate the TPS 
sub calculateTPS {
  
    my $fileName = $_[0];
    open READFILE, "<", "$fileName" or die "can't open logfile $fileName!";

    my %lines = ();
    while(<READFILE>) {
        chomp;
        s/(.*)-0500.*/\1/;
        if (! exists $lines{$_}) {
                $lines{$_} = 1;
        }
        else {
                $lines{$_} = $lines{$_} + 1;
        }
    }
    close READFILE;

    #foreach $key(sort keys %lines) {
    #    print "$key = $lines{$key} \n";
    #}
   
    my $maxKey;
    my $maxValue = -1;
    my $minValue = 100;
    #my $totalValue=0;
    while (my ($key, $value) = each %lines) {
        if ($maxValue < $value)
        {
        	$maxValue=$value;
        	$maxKey=$key;
        }
        if ($minValue > $value)
        {
             $minValue = $value;
        }
        #$totalValue = $totalValue + $value;
       # print "$key key has a value $value \n";
    }
   
    #Calculate Mean/AVG of tps. 
    #my @keys = keys %lines;
    #my $size = @keys;
    #my $meanValue = $totalValue / $size;
     
    print " FileName = $fileName. $maxKey key has the highest value= $maxValue\n";

     # Write max tps data into csv file 
     my $csvfile ="TPSReulst.csv";
     open  CSVFILE,">>$csvfile" or die "can't open csv file for writing!";
     $fileName=~s/.*logs\/(.*)\.txt.*/\1/;
     my $API2 =$1; 
     print "API2 =$API2\n"; 
     $maxKey=~s/.*\[(.*)\s*.*/\1/;
     print "time in key field = $1\n";
     print " API = $API2;  max tps = $maxValue; min tps = $minValue\n";
     print CSVFILE " FileName = $fileName. $maxKey key has the highest value= $maxValue\n";
     close CSVFILE;
}

###### Main Routine ########
open READFILE, "<", "$ARGV[0]" or die "can't open logfile $ARGV[0]!";

$LOGFILE = $ARGV[0];

%api = ();

while (<READFILE>) {

      chomp;
      s/.*\/contacts\/v1\/([a-z|A-Z]+).*/\1/;
     # print "$1\n";
     
      #insert into hash
     if (!exists $api{$1}) {
     
       $api{$1} = 1;
     }
     else {
       $api{$1} = $api{$1} + 1;
    }
}
    
close READFILE;


#@keys = keys %api;
#$size = @keys;
#print "Total element number is : $size\n";

print "***** below is the hash contents*****\n";
foreach $key(sort keys %api ) {
  #   print " $key = $api{$key} \n";
     genAPIFile($key);
}

#call sub processAPIFile
processAPIFile();
#calculateTPS("./logs/termsAndConditions.txt");


  


