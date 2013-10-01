use 5.008008;
use ExtUtils::MakeMaker qw(WriteMakefile prompt);

my %config = (
    NAME         => 'Win32::SqlServer::DTS',
    VERSION_FROM => 'lib/Win32/SqlServer/DTS.pm',    # finds $VERSION
    PREREQ_PM    => {
        'Class::Accessor'  => 0.25,
        'Hash::Util'       => 0.05,
        'Win32::OLE'       => 0.1704,
        'Carp'             => 1.04,
        'DateTime'         => 0.35,
        'Class::Publisher' => 0.2,
        'Devel::AssertOS'  => 0,
        'XML::Simple'      => 2.18, 
		'Params::Validate' => 0
    },
    META_MERGE => {
        resources => {
            license  => 'http://www.gnu.org/licenses/old-licenses/gpl-2.0.html',
            homepage => 'http://code.google.com/p/perldts/',
            bugtracker => 'http://code.google.com/p/perldts/issues/list',
            repository => 'http://code.google.com/p/perldts/source/browse/'
        },
    },
    LICENSE => 'GNU General Public License (GPL)',
    dist    => { SUFFIX => '.gz', COMPRESS => 'gzip --best' },
    (
        $] >= 5.005
        ?    ## Add these new keywords supported since 5.005
          (
            ABSTRACT_FROM =>
              'lib/Win32/SqlServer/DTS.pm',    # retrieve abstract from module
            AUTHOR => 'Alceu Rodrigues de Freitas Junior <arfreitas@cpan.org>'
          )
        : ()
    ),
);

my @patterns = qw( t/*.t );

print
"You can enable extended tests if the environment was prior configured. See README for more information\n";
my $answer = prompt( 'Do you want to enable extended tests?', 'no' );

if ( $answer =~ /^y/i ) {

    print "Running extended tests.\n";
    push @patterns, 't/extended/*.t';

}
else {

    print "Skipping extended tests.\n";

}

$config{test} = { TESTS => join ' ', map { glob } @patterns };
WriteMakefile(%config);

