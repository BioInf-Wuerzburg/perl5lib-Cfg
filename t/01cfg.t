#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;
use Test::Deep;
use Data::Dumper;

use FindBin qw($RealBin);
use lib "$RealBin/../lib/";

use Log::Log4perl qw(:easy :levels);
Log::Log4perl->init(\q(
        log4perl.rootLogger                               = DEBUG, Screen
        log4perl.appender.Screen                          = Log::Log4perl::Appender::Screen
        log4perl.appender.Screen.stderr                   = 1
        log4perl.appender.Screen.layout                   = PatternLayout
        log4perl.appender.Screen.layout.ConversionPattern = [%d{MM-dd HH:mm:ss}] [%C] %m%n
));


#--------------------------------------------------------------------------#
=head2 load module

=cut

BEGIN { use_ok('Cfg'); }

my $Class = 'Cfg';

#--------------------------------------------------------------------------#
=head2 sample data

=cut


# create data file names from name of this <file>.t
(my $Dat_file = $FindBin::RealScript) =~ s/t$/dat/; # data
(my $Dmp_file = $FindBin::RealScript) =~ s/t$/dmp/; # data structure dumped
(my $Tmp_file = $FindBin::RealScript) =~ s/t$/tmp/; # data structure dumped
(my $pre = $FindBin::RealScript) =~ s/.t$//; # data structure dumped

my ($Dat, %Dat, %Dmp);

if(-e $Dat_file){
	# slurp <file>.dat
	$Dat = do { local $/; local @ARGV = $Dat_file; <> }; # slurp data to string
	# %Dat = split("??", $Dat);
}

if(-e $Dmp_file){
    # eval <file>.dump
    %Dmp = do "$Dmp_file"; # read and eval the dumped structure
}


#-----------------------------------------------------------------------------##
=head1 ClassMethods

=cut

can_ok($Class, qw(Read Read_Cfg Copy Copy_Cfg)); # including back-comp aliases


##- Read ---------------------------------------------------------------------##
my %c1 = (
  log => "path/to/somewhere",
  
  servers => [
    "foo", "bar"
  ],
  
  more => {
    complex => [qw( s t u f f )]
  },
);

my %c2 = Cfg->Read($Dat_file);


cmp_deeply(\%c1, \%c2, "Read");

##- Copy_Cfg -----------------------------------------------------------------##
unlink($Tmp_file);
Cfg->Copy($Dat_file, $Tmp_file);

cmp_deeply(\%c1, {Cfg->Read($Tmp_file)}, "Copy");


done_testing();
