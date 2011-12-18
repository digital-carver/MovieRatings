use IMDB::Film;
use strict;
use warnings;
use Getopt::Long;

my @problems;
main();

sub main {

my $reverse;
my $verbose = 1;
my @ratings = qw();

my $result = GetOptions("verbose!" => \$verbose, 
                        "reverse!" => \$reverse, 
                        );

my $root_dir = $ARGV[0];

if (not -d $root_dir) {
    die "Sorry, $root_dir doesn't look like a directory to me. Bailing out.";
}

look_into($root_dir, $verbose);

print "By the way, we had problems fetching info for these: \n" if @problems;
for my $p (@problems) {
    print $p, "\n";
}
}


sub look_into
{
my ($dir_path, $verbose) = shift;
print "Okay, gonna look into $dir_path now..." if $verbose;

opendir(my $dir, $dir_path) or die "Aw shucks, unable to open $dir_path. $!\n";

while (my $f = readdir($dir)) {
    if (-d $f && $f ne '..' && $f ne '.') {
        my $movie_name = $1;
        my $imdb_obj = new IMDB::Film(crit => $movie_name);
        if ($imdb_obj->status()) {
            print $imdb_obj->mpaa_info();
        }
        else {
            push @problems, $f;
        }
    }
    elsif (-f $f && ($f =~ /^(.*)\.avi$/ || $f =~ /(.*)\.mp4/)) {
        look_into($f, $verbose);
    }
}
}
