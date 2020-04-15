#!/usr/bin/perl -w
# serve data from prepared DB files
use strict;
use CGI ":standard";
use DB_File;

our $datadir = "/usr/local/share/impryo/";
our @distributions = qw(openSUSE ArchLinux Debian);

my $pkg = "bash";
my %pkgstatus;

for my $d (@distributions) {
    my $dbname = "$datadir\L$d.db";
    my %data;
    tie(%data, "DB_File", $dbname, O_RDONLY) or die "error opening DB $dbname: $!";
    $pkgstatus{$d} = $data{$pkg};
    untie %data;
}

print header("text/html").start_html(-title=>"ismypackagereproducibleyet");
for my $d (@distributions) {
    print "$d : $pkgstatus{$d}<br/>\n";
}
print end_html;
