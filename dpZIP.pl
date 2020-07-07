#!/usr/bin/perl -w

$auctionsite = $ARGV[0];
$filepath = $ARGV[1];
$output = `curl --compressed "$auctionsite" -o "$filepath"`;