#!/usr/bin/perl -w
# serve data from prepared DB files
use strict;
use CGI ":standard";
use DB_File;

our $datadir = "/usr/local/share/impryo/";
our $cssbase = "/css/"; # needs trailing slash
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

print header("text/html"),
    start_html(-title=>"ismypackagereproducibleyet",
        -style=>"${cssbase}main.css",
        -head=>Link({-rel=>"shortcut icon", -href=>"/css/favicon.png"}));

print
    start_form(-name=>'form', -method=>'get'),
    textfield(-name=>'pkg', -class=>'text'),
    submit(-name=>'query', -class=>'smbutton'),
    end_form.br.p;
print "Is <b>$pkg</b> reproducible in", br;

my $pkgstatus = get_pkgstatus($pkg);
for my $d (@distributions) {
    my $s = $pkgstatus->{$d} || 'not found';
    my $statusclass = $s;
    $statusclass =~ s/FTBR_\d+/FTBR/; # for ArchLinux
    my $answer=($s eq "reproducible" ? "yes" : $s =~ /FTBR/ ? "no" : "dont know");
    print "<span class=\"distribution\">$d</span> : <span class=\"$statusclass\"><b>$answer</b>: $s</span><br/>\n";
}

print br,a({-href=>"https://maintainer.zq1.de/?pkg=$pkg"}, "find more info about $pkg");
print br,a({-href=>'https://github.com/bmwiedemann/ismypackagereproducibleyet'}, 'contribute feedback');
print end_html;
