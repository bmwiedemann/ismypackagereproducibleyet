#!/usr/bin/perl -w
# serve data from prepared DB files
use strict;
use CGI ":standard";
use DB_File;

our $datadir = "/usr/local/share/impryo/";
our @distributions = qw(openSUSE ArchLinux Debian);

sub get_pkgstatus($)
{ my $pkg = shift;
    my %pkgstatus;
    for my $d (@distributions) {
        my $dbname = "$datadir\L$d.db";
        my %data;
        tie(%data, "DB_File", $dbname, O_RDONLY) or die "error opening DB $dbname: $!";
        $pkgstatus{$d} = $data{$pkg};
        untie %data;
    }
    return \%pkgstatus;
}

my $pkg = param("pkg") || "bash";
$pkg =~ s/[^a-zA-Z0-9_.+-]//g; # sanitize untrusted user input
param("pkg", $pkg);

print header("text/html").start_html(-title=>"ismypackagereproducibleyet", -style=>"/impryo/main.css");

print
    start_form(-name=>'form', -method=>'get'),
    textfield(-name=>'pkg', -class=>'text'),
    submit(-name=>'query', -class=>'smbutton'),
    end_form.br.p;

my $pkgstatus = get_pkgstatus($pkg);
for my $d (@distributions) {
    my $s = $pkgstatus->{$d} || '?';
    print "<span class=\"distribution\">$d</span> : <span class=\"$s\">$s</span><br/>\n";
}

print br,a({-href=>"https://maintainer.zq1.de/?pkg=$pkg"}, "find more info about $pkg");
print br,a({-href=>'https://github.com/bmwiedemann/ismypackagereproducibleyet'}, 'contribute feedback');
print end_html;
