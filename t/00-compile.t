use 5.006;
use strict;
use warnings;

# this test was generated with Dist::Zilla::Plugin::Test::Compile 2.039

use Test::More  tests => 10 + ($ENV{AUTHOR_TESTING} ? 1 : 0);



my @module_files = (
    'Perinci/Examples.pm',
    'Perinci/Examples/CLI.pm',
    'Perinci/Examples/CmdLineResMeta.pm',
    'Perinci/Examples/CmdLineSrc.pm',
    'Perinci/Examples/Completion.pm',
    'Perinci/Examples/FilePartial.pm',
    'Perinci/Examples/FileStream.pm',
    'Perinci/Examples/NoMeta.pm',
    'Perinci/Examples/SubMeta.pm',
    'Perinci/Examples/Tx.pm'
);



# no fake home requested

my $inc_switch = -d 'blib' ? '-Mblib' : '-Ilib';

use File::Spec;
use IPC::Open3;
use IO::Handle;

open my $stdin, '<', File::Spec->devnull or die "can't open devnull: $!";

my @warnings;
for my $lib (@module_files)
{
    # see L<perlfaq8/How can I capture STDERR from an external command?>
    my $stderr = IO::Handle->new;

    my $pid = open3($stdin, '>&STDERR', $stderr, $^X, $inc_switch, '-e', "require q[$lib]");
    binmode $stderr, ':crlf' if $^O eq 'MSWin32';
    my @_warnings = <$stderr>;
    waitpid($pid, 0);
    is($?, 0, "$lib loaded ok");

    if (@_warnings)
    {
        warn @_warnings;
        push @warnings, @_warnings;
    }
}



is(scalar(@warnings), 0, 'no warnings found') if $ENV{AUTHOR_TESTING};


