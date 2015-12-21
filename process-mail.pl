#!/usr/local/bin/perl
#
#  Reads mail for subscribe@flaminghakama.com (or subscribe@<domain> specified by -domain <domain> )
#  Extracts senders from new mail and logs it
#  copys new mail files to processed directory
#
use strict;
use Getopt::Std;
use File::Copy;

my %args;
getopt('domain', \%args);
my $domain = shift || 'flaminghakama.com';

#  Define the location of things
my $homeDir = '/home1/elaine' ;
my $mailDir = "$homeDir/mail" ;
my $domainDir = "$mailDir/$domain" ;
my $accountDir = "$domainDir/subscribe" ;
my $newEmailDir = "$accountDir/test-new" ;
$newEmailDir = "$accountDir/new" ;
my $processedEmailDir = "$accountDir/processed" ;

#  Open the log file for appending
my $logfile = "$accountDir/subscribe.log" ;
my $logError = "Could not open log file '$logfile':" ;
my $openError ; 
my $copyError ; 
open(my $log, '>>', $logfile) or die "$logError $!" ;
print $log localtime() . "\n" ;

#  Gather the new emails 
opendir(NEWEMAIL, $newEmailDir);
my @emailFileNames = readdir(NEWEMAIL);
closedir(NEWEMAIL);
my $newEmail ; 
my $processedEmail ; 
my @previouslyProcessed ; 
my $person ; 

#
#  Loops through the lines of an email file
#  Finds the first From: address and returns that information
#
sub getPersonFromEmail {

    my ($email) = @_ ; 
    my $person ; 
    while (my $row = <$email>) {

        next unless ( $row =~ /^\s*From\:/i ) ; 

        next if ( $row =~ /elaine\@flaminghakama\.com/ ); 
        next if ( $row =~ /dalt\@wsgc\.com/ ); 
        next if ( $row =~ /bird\@alum\.mit\.edu/ ); 
        next if ( $row =~ /my_public_email\@yahoo\.com/ ); 

        ($person) = ( $row =~ /^\s*From:\s*(.*)/i ) ;         
        if ( $person ) { 
            return $person ; 
        }
    }
    return '' ; 
}

#
#  Returns true if the new email file exists and the processed file does not exist.
#
sub hasNotBeenProcessed {

    my ($newEmail, $processedEmail) = @_ ; 

    return ( -f $newEmail ) && ( ! -f $processedEmail ) ; 
}

#  Process each new email
foreach my $emailFileName (@emailFileNames) {
    next if($emailFileName =~ /^\.$/);
    next if($emailFileName =~ /^\.\.$/);

    $newEmail = "$newEmailDir/$emailFileName" ;
    $processedEmail = "$processedEmailDir/$emailFileName" ;

    $openError = "Could not open file '$newEmail':" ;
    open(my $email, '<:encoding(UTF-8)', $newEmail) or die "$openError $!" ;

    $person = getPersonFromEmail($email) ; 
    if ( hasNotBeenProcessed($newEmail, $processedEmail) ) { 
        if ( $person ) { 
            print $log $person . "\n" ; 
        }
    } else {
        push (@previouslyProcessed, "$emailFileName (person: '$person')") ; 
    }
    close $email ;

    $copyError = "Could not copy new email '$newEmail' to '$processedEmail':" ; 
    copy($newEmail, $processedEmail) or die "$copyError $!" ;
}
print $log join("\n    ", "Previously processed subscriptions: ", @previouslyProcessed) ;

close $log ; 
