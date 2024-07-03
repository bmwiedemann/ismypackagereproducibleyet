#!/usr/bin/env perl
# parsing 100MB of json for every page view is too slow
# so we pre-process that data into DB files

use strict;
use warnings;
use DB_File;
use JSON::XS;

my $outfile = shift or die "usage: $0 OUTPUT.db < INPUT.json";
my $isarch = $outfile=~m/archlinux/;
local $/;
my $pkgs = decode_json(<>);
my %dbdata;

foreach my $pkg (@$pkgs) {
    #print $pkg->{package}," ", $pkg->{status},"\n";
    my $status = $pkg->{status};
    $status =~ s/unreproducible/FTBR/; # openSUSE->Debian format
    # Archlinux mapping:
    if($isarch) {
        $status =~ s/BAD/FTBR/;
        if(!$pkg->{has_diffoscope}) {$status=~s/FTBR/FTBFS/}
        $status =~ s/UNKWN/waitdep/;
        $status =~ s/GOOD/reproducible/;
    }
    $pkg->{suite}||="";
    next if $pkg->{suite} eq "experimental";
    $pkg->{package} ||= $pkg->{name}; # for Archlinux
    $dbdata{$pkg->{package}} = $status;
}

my %tiedata;
tie(%tiedata, "DB_File", $outfile) or die "error opening DB: $!";
%tiedata = %dbdata;
untie(%tiedata);
