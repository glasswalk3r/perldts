use 5.008008;
use ExtUtils::MakeMaker qw(WriteMakefile prompt);

my %config = (
    NAME         => 'DTS',
    VERSION_FROM => 'lib/DTS.pm',    # finds $VERSION
    PREREQ_PM    => {
        'Class::Accessor'  => 0.25,
        'Hash::Util'       => 0.05,
        'Win32::OLE'       => 0.1704,
        'Carp'             => 1.04,
        'DateTime'         => 0.35,
        'Class::Publisher' => 0.2
    },
    (
        $] >= 5.005
        ?    ## Add these new keywords supported since 5.005
          (
            ABSTRACT_FROM => 'lib/DTS.pm',    # retrieve abstract from module
            AUTHOR =>
              'Alceu Rodrigues de Freitas Junior <arfreitas@cpan.org>'
          )
        : ()
    ),
);

my @patterns = qw( t/*.t );

print
"You can enable extended tests if the environment was configured prior the execution of this tests. See README for more information\n";
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

