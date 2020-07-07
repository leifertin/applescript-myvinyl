#!/usr/bin/perl -w
 
$path = $ARGV[0];
$lns = $ARGV[1];
 
# Read the file.
if (open(FILE,"$path")) {
    @the_file=<FILE>;
    close(FILE);
} else {
    die "Could not open file.\n";
}
 
# 21 is the number of lines to remove.
for ($i = 0; $i < $lns; $i++) {
    splice(@the_file,0,1);
}
 
# Write the remaining 20 lines.
if (open(FILE,">$path")) {
    print FILE (@the_file);
    close(FILE);
} else {
    die "Could not open file.\n";
}