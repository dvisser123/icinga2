#!/usr/local/bin/perl
#
# Check status of systemd and units 
#
# $Header: /home/doke/work/nagios/RCS/check_systemd,v 1.5 2016/11/17 22:05:15 doke Exp $


use strict;
use warnings;
use Getopt::Long;
#use Data::Dumper;

use vars qw( $verbose $help @crits @warns @unknowns @oks @ignores );

$ENV{PATH} = "/usr/bin";

$ENV{LANG} = "POSIX";  # or systemctl outputs weird characters
$ENV{LANGUAGE} = "POSIX";  
$ENV{LC_ALL} = "POSIX";  

$verbose = 0;
$help = 0;

sub usage {
    my( $rc ) = @_;
    print "Usage: $0 [-vh]
    -v    verbose
    -h    help
";
    exit $rc;
    }

Getopt::Long::Configure ("bundling");
GetOptions(
    'v+' => \$verbose,
    'h' => \$help,
    );
usage( 0 ) if ( $help );

&check_systemd();

my $rc = 0;
my $sep = '';
if ( $#crits >= 0 ) {
    $rc = 2;
    print "CRITICAL ", join( ", ", @crits );
    $sep = '; ';
    }
if ( $#warns >= 0 ) {
    $rc = 1 if ( $rc == 0 );
    print $sep, "Warning ", join( ", ", @warns );
    $sep = '; ';
    }
if ( $#unknowns >= 0 ) {
    $rc = -1 if ( $rc == 0 );
    print $sep, "Unknown ", join( ", ", @unknowns );
    $sep = '; ';
    }
if ( $rc == 0 ) {
    print "Ok ", join( ", ", @oks );
    $sep = '; ';
    }
if ( $#ignores >= 0 ) {
    print $sep, "Ignoring ", join( ", ", @ignores );
    }

print "\n";
exit $rc;


##################



sub check_systemd {
    my( $cmd, $unit, $load, $active, $sub, $descr );

    if ( ! -x "/usr/bin/systemctl" ) { 
	push @oks, "not applicable, systemd not installed"; 
	return;
	}

    $cmd = "/usr/bin/systemctl list-units --state=failed";
    $verbose && print "+ $cmd\n"; 
    if ( ! open( pH, '-|', $cmd ) ) { 
	push @unknowns, "can't run systemctl\n";
	return;
	}

#      UNIT             LOAD   ACTIVE SUB    DESCRIPTION
#    * sendmail.service loaded failed failed Sendmail Mail Transport Agent

    foreach ( <pH> ) { 
	$verbose && print "< $_";
	chomp;
	if ( m/^\s* \*? \s* ([\w\d\._-]+) \s+ (\w+) \s+ (\w+) 
		\s+ (\w+) \s+ (.+) \s*$/ix ) { 
	    $unit = $1;
	    $load = $2;
	    $active = $3;
	    $sub = $4;
	    $descr = $5;
	    $verbose && print "> $unit $load $active $sub $descr\n";

	    if ( ( $active eq "failed" || $sub eq "failed" ) 
		    && $load ne 'masked' ) { 
		$verbose && print "crit: $active $sub $unit $descr\n";
		push @crits, "$unit has failed"; 
		}
	    }
	}
    close pH; 

    push @oks, "no failed units";
    return;
    }




