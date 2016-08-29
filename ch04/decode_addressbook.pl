#!/usr/bin/perl

use strict;

mkdir("./addressbook-output", 0755);
while(<STDIN>) {
    next unless (/^INSERT INTO/);
    my($insert, $query) = split(/\(/);
    my($idx, $data) = (split(/\,/, $query))[1,5];
    my($head, $raw, $tail) = split(/\'/, $data);
    decode($idx, $raw);
}
exit(0);

sub decode {
    my($idx, $data) = @_;
    my $j = 0;
    my $filename = "./addressbook-output/$idx.png";
    print "writing $filename...\n";
    next if int(length($data))<128;
    open(OUT, ">$filename") || die "$filename: $!";
    while($j < length($data)) {
        my $hex = "0x" . substr($data, $j, 2);
        print OUT chr(hex($hex));
        $j += 2;
    }
    close(OUT);
}

