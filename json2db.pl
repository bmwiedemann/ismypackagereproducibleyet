#!/usr/bin/perl -w
# parsing 100MB of json for every page view is too slow
# so we pre-process that data into DB files

use strict;
use DB_File;
use JSON::XS;

my $outfile = shift or die "usage: $0 OUTPUT.db < INPUT.json";
local $/;
my $pkgs = decode_json(<>);
my %dbdata;

foreach my $pkg (@$pkgs) {
    #print $pkg->{package}," ", $pkg->{status},"\n";
    $pkg->{status} =~ s/unreproducible/FTBR/;
    $dbdata{$pkg->{package}} = $pkg->{status};
}

my %tiedata;
tie(%tiedata, "DB_File", $outfile) or die "error opening DB: $!";
%tiedata = %dbdata;
untie(%tiedata);
