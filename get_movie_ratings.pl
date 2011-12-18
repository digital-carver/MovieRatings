use IMDB::Film;
use strict;
use warnings;
use Getopt::Long;
use File::Find;

my @problems;
my $verbose = 1;
main();

sub main {

my $reverse;
my @ratings = qw();

my $result = GetOptions("verbose!" => \$verbose, 
                        "reverse!" => \$reverse, 
                        );

my $root_dir = $ARGV[0];

if (not -d $root_dir) {
    die "Sorry, $root_dir doesn't look like a directory to me. Bailing out.";
}

find(\&process, $root_dir);

print "By the way, we had problems fetching info for these: \n" if (@problems && $verbose);
for my $p (@problems) {
    print $p, "\n";
}
print "Number of problematic files: " . int(@problems);
}

sub process {
my $f = $_;
if (-f $f && ($f =~ /^(.*)\.avi$/ || $f =~ /(.*)\.mp4/) && $1 ne 'Sample') {
    print "Next file: $f\n" if $verbose;
    my $movie_name = $1;
    #Remove unnecessary parts from the filename
    for my $to_remove qw(aXXo DvDrip Eng DivX DvDScr) {
        $movie_name =~ s/\b$to_remove\b//i;
    }
    #Remove empty brackets that might be left from the previous
    for my $to_remove qw<() [] {} ||> {
        $movie_name =~ s/\s*\Q$to_remove\E\s*/ /i;
    }
    #Change the year from .year to (year)
    if ($movie_name =~ /(.*)\.(\d{4})$/) {
        $movie_name = $1 . " (" . $2 . ")";
    }
    my $imdb_obj = new IMDB::Film(crit => $movie_name);
    if ($imdb_obj->status()) {
        print "RATING: ", $imdb_obj->mpaa_info(), "\n";
    }
    else {
        push @problems, $f;
    }
}
elsif (-d $f && $f ne '..' && $f ne '.') {
    print "Okay, gonna look into $f now..." if $verbose;
}
}

