#!/usr/bin/perl
#==============================================================
# Project: Cxl, Cxxlint
# Function: A perl script for automating cxxlint for use on a web server.
#
# Author: Tom Graham, tgraham@wpi.edu
#==============================================================
use strict;
use warnings;

my $script = $ARGV[1];
my $fileName = $ARGV[0];
my $resultDir = $ARGV[2];

#==============================================================
# Extraction and file directory management:
#==============================================================
my $fileCount = 0;
my $fileCheck = "file $fileName";

if ((`$fileCheck`) =~ "No such file or directory"){
    exit;
}
else{
	(`unzip -qq $fileName -d temp`);
}

$fileCount = (`ls temp | wc -l`);

#==============================================================
# Build and execute python command for cpplint:
#==============================================================
my $cmd2 = "python $script --verbose=5 --exclude=*/ --exclude=*.zip --exclude=*.txt --quiet --root=chrome/browser temp/*";
	(`$cmd2 1>>scriptRaw.txt 2>&1`);

#==============================================================
# Sort through the files, and count errors:
#==============================================================
open my $inFile, '<', 'scriptRaw.txt';
open my $outFile, '>', 'style.txt';

my $whitespaceCount = 0;
my $runtimeCount = 0;
my $copyrightCount = 0;
my $readabilityCount = 0;
my $includeCount = 0;

print $outFile "\n";

my @file = <$inFile>;
foreach my $line (@file)
{
	my $math = length($line) - 4;
	$line = substr($line, 5, $math);

	#TODO
	my $f = "Can't open for reading";
	my $f2 = "header_guard";
	my $f3 = "None";

	print $outFile $line unless ($line =~ $f || $line =~ $f2 || $line =~ $f3);

	if ($line =~ "whitespace"){
		$whitespaceCount++;
	}
	if ($line =~ "legal"){
		$copyrightCount++;
	}
	if ($line =~ "runtime"){
		$runtimeCount++;
	}
	if ($line =~ "readability"){
		$readabilityCount++;
	}
	if ($line =~ "include"){
		$includeCount++;
	}
}

#==============================================================
# Calculate score:
# TODO: configure includeCount to work
#==============================================================
my $totalErrors = $runtimeCount + $copyrightCount + $whitespaceCount + $readabilityCount + $includeCount;
my $maxScore = 10;

my $actualScore =  $maxScore - $totalErrors;

if ($totalErrors > 10){
	$actualScore = 0;
}

#==============================================================
# Generate a readable report:
#==============================================================
open my $f, '<', 'scriptRaw.txt';
open my $outFile2, '>', 'styleSummary.txt';
print $outFile2 "\n";
print $outFile2 "Total files processed:\t\t\t $fileCount";
print $outFile2 "-------- \n";
print $outFile2 "Whitespace or parenthesis errors: \t $whitespaceCount \n";
print $outFile2 "Readability Errors \t \t $readabilityCount \n";
print $outFile2 "Copyright or legal errors: \t\t $copyrightCount \n";
print $outFile2 "Runtime or explicit errors: \t\t $runtimeCount \n\n";
print $outFile2 "Include errors: \t\t $includeCount \n\n";
print $outFile2 "Total Errors \t\t\t\t$totalErrors\n";
print $outFile2 "Score:\t\t\t\t\t $actualScore";

#==============================================================
# Clean up:
#==============================================================
close $inFile, $outFile, $outFile2, $f;

(`mv style.txt $resultDir`);
(`mv scriptRaw.txt $resultDir`);
(`rm -R temp/ && rm $resultDir/1-stdout.txt`);
## (`rm -R temp/ && rm scriptRaw.txt && rm $resultDir/1-stdout.txt`);
##-------------------------------------------------------------
exit(0);
#--------------------------------------------------------------
