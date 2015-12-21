#!/usr/local/bin/perl
#
#  Finds the person who sent the email in the specified mail file.
#
#  find-person.pl <mail file>+
#
use strict;

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


my $openError ; 
my $email ; 
my $person ; 

#  Process each new email
foreach my $emailFile (@ARGV) {
    next if($emailFile =~ /^\.$/);
    next if($emailFile =~ /^\.\.$/);

    $openError = "Could not open file '$emailFile':" ;
    open(my $email, '<:encoding(UTF-8)', $emailFile) or die "$openError $!" ;

    $person = getPersonFromEmail($email) ; 
    print "person in $emailFile is '$person'\n" ; 
    close $email ;
}
