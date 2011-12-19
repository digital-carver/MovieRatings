use strict;
use warnings;
use Getopt::Long;
use File::Find;
use IMDB::Film;

my @problems;
my $verbose;
my $print_path = 1;
main();

sub main {

my $reverse;
my @ratings = qw();

my $result = GetOptions("verbose!" => \$verbose, 
                        "reverse!" => \$reverse, 
                        "print_path|pp!" => \$print_path,
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
    my $movie_name = get_movie_name($1);
    print "#Searching $movie_name for file $f\n" if $verbose;
    my ($rating, $name_used) = get_rating($movie_name);
    if ($rating) {
        printf("%-40s :: ", $name_used); 
        printf("%-40s\n", $rating);
        printf("#[For file: %s]\n", $File::Find::name) if $print_path;
    }
}
elsif (-d $f && $f ne '..' && $f ne '.') {
    print "#Okay, gonna look into $f now...\n" if $verbose;
}
}

sub get_movie_name
{
my $movie_name = shift;
#Remove unnecessary parts from the filename
for my $to_remove qw(DvDrip DvDScr Eng DivX XviD LTT aXXo CD\d) {
    $movie_name =~ s/\b$to_remove\b//ig;
}
#Remove empty brackets that might be left from the previous
for my $to_remove qw<() [] {} ||> {
    $movie_name =~ s/\s*\Q$to_remove\E\s*/ /g;
}
#Remove spurious left-behind hyphens
$movie_name =~ s/\s*-\s*$//g;
#If dot separated, change to space
$movie_name =~ s/(\w)\.(\w)/$1 $2/g;
#Change the year from .year to (year)
if ($movie_name =~ /(.*)\.(\d{4})$/ || $movie_name =~ /(.*)\s*\[(\d{4})\W*\]$/) {
    $movie_name = $1 . " (" . $2 . ")";
}
return $movie_name;
}

sub get_rating
{
    my $movie_name = shift;
    my $imdb_obj = new IMDB::Film(crit => $movie_name);
    if ($imdb_obj->status()) {
        return ($imdb_obj->mpaa_info(), $imdb_obj->title());
    }
    else {
        print STDERR "!!Problem with $movie_name\n" if $verbose;
        return ("", "");
    }
}

