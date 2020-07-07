#!/usr/bin/perl -w

$auctionsite = $ARGV[0];
$filepath = $ARGV[1];
$output = `curl "$auctionsite" -o "$filepath"`;