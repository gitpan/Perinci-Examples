package Perinci::Examples;

use 5.010001;
use strict;
use warnings;
use Log::Any '$log';

use Data::Clone;
use List::Util qw(min max);
use Scalar::Util qw(looks_like_number);

our $VERSION = '0.18'; # VERSION

our @ISA = qw(Exporter);
our @EXPORT_OK = qw(
                       delay dies err randlog
                       gen_array gen_hash
                       noop
               );
our %SPEC;

# package metadata
$SPEC{':package'} = {
    v => 1.1,
    summary => 'This package contains various examples',
    "summary.alt.lang.id_ID" => 'Paket ini berisi berbagai contoh',
    description => <<'_',

A sample description

    verbatim
    line2

Another paragraph with *bold*, _italic_ text.

_
};

# variable metadata
$SPEC{'$Var1'} = {
    v => 1.1,
    summary => 'This variable contains the meaning of life',
};
our $Var1 = 42;

# as well as testing default_lang and *.alt.lang.XX properties
$SPEC{delay} = {
    v => 1.1,
    default_lang => 'id_ID',
    "summary.alt.lang.en_US" => "Sleep, by default for 10 seconds",
    "description.alt.lang.en_US" => <<'_',

Can be used to test the *time_limit* property.

_
    summary => "Tidur, defaultnya 10 detik",
    description => <<'_',

Dapat dipakai untuk menguji properti *time_limit*.

_
    args => {
        n => {
            default_lang => 'en_US',
            summary => 'Number of seconds to sleep',
            "summary.alt.lang.id_ID" => 'Jumlah detik',
            schema => ['int', {default=>10, min=>0, max=>7200}],
            pos => 0,
        },
        per_second => {
            "summary.alt.lang.en_US" => 'Whether to sleep(1) for n times instead of sleep(n)',
            summary => 'Jika diset ya, lakukan sleep(1) n kali, bukan sleep(n)',
            schema => ['bool', {default=>0}],
        },
    },
};
sub delay {
    my %args = @_; # NO_VALIDATE_ARGS
    my $n = $args{n} // 10;

    if ($args{per_second}) {
        sleep 1 for 1..$n;
    } else {
        sleep $n;
    }
    [200, "OK", "Slept for $n sec(s)"];
}

$SPEC{dies} = {
    v => 1.1,
    summary => "Dies tragically",
    description => <<'_',

Can be used to test exception handling.

_
    args => {
    },
};
sub dies {
    my %args = @_;
    die;
}

$SPEC{err} = {
    v => 1.1,
    summary => "Return error response",
    description => <<'_',


_
    args => {
        code => {
            summary => 'Error code to return',
            schema => ['int' => {default => 500}],
        },
    },
};
sub err {
    my %args = @_; # NO_VALIDATE_ARGS
    my $code = int($args{code}) // 0;
    $code = 500 if $code < 100 || $code > 555;
    [$code, "Response $code"];
}

my %str_levels = qw(1 fatal 2 error 3 warn 4 info 5 debug 6 trace);
$SPEC{randlog} = {
    v => 1.1,
    summary => "Produce some random Log::Any log messages",
    description => <<'_',

_
    args => {
        n => {
            summary => 'Number of log messages to produce',
            schema => [int => {default => 10, min => 0, max => 1000}],
            pos => 0,
        },
        min_level => {
            summary => 'Minimum level',
            schema => ['int*' => {default=>1, min=>0, max=>6}],
            pos => 1,
        },
        max_level => {
            summary => 'Maximum level',
            schema => ['int*' => {default=>6, min=>0, max=>6}],
            pos => 2,
        },
    },
};
sub randlog {
    my %args      = @_; # NO_VALIDATE_ARGS
    my $n         = $args{n} // 10;
    $n = 1000 if $n > 1000;
    my $min_level = $args{min_level};
    $min_level = 1 if !defined($min_level) || $min_level < 0;
    my $max_level = $args{max_level};
    $max_level = 6 if !defined($max_level) || $max_level > 6;

    for my $i (1..$n) {
        my $num_level = int($min_level + rand()*($max_level-$min_level+1));
        my $str_level = $str_levels{$num_level};
        $log->$str_level("($i/$n) This is random log message #$i, ".
                             "level=$num_level ($str_level): ".
                                 int(rand()*9000+1000));
    }
    [200, "OK", "$n log message(s) produced"];
}

$SPEC{call_randlog} = clone($SPEC{randlog});
$SPEC{call_randlog}{summary} = 'Call randlog()';
$SPEC{call_randlog}{description} = <<'_';

This is to test nested call (e.g. Log::Any::For::Package).

_
sub call_randlog {
    # NO_VALIDATE_ARGS
    randlog(@_);
}

$SPEC{gen_array} = {
    v => 1.1,
    summary => "Generate an array of specified length",
    description => <<'_',

Also tests result schema.

_
    args => {
        len => {
            summary => 'Array length',
            schema => ['int' => {default=>10, min => 0, max => 1000}],
            pos => 0,
            req => 1,
        },
    },
    result => {
        schema => ['array*', of => 'int*'],
    },
};
sub gen_array {
    my %args = @_; # NO_VALIDATE_ARGS
    my $len = int($args{len});
    defined($len) or return [400, "Please specify len"];
    $len = 1000 if $len > 1000;

    my $array = [];
    for (1..$len) {
        push @$array, int(rand()*$len)+1;
    }
    [200, "OK", $array];
}

$SPEC{call_gen_array} = clone($SPEC{gen_array});
$SPEC{call_gen_array}{summary} = 'Call gen_array()';
$SPEC{call_gen_array}{description} = <<'_';

This is to test nested call (e.g. Log::Any::For::Package).

_
sub call_gen_array {
    # NO_VALIDATE_ARGS
    gen_array(@_);
}

$SPEC{gen_hash} = {
    v => 1.1,
    summary => "Generate a hash with specified number of pairs",
    description => <<'_',

Also tests result schema.

_
    args => {
        pairs => {
            summary => 'Number of pairs',
            schema => ['int*' => {min => 0, max => 1000}],
            pos => 0,
        },
    },
    result => {
        schema => ['array*', of => 'int*'],
    },
};
sub gen_hash {
    my %args = @_; # NO_VALIDATE_ARGS
    my $pairs = int($args{pairs});
    defined($pairs) or return [400, "Please specify pairs"];
    $pairs = 1000 if $pairs > 1000;

    my $hash = {};
    for (1..$pairs) {
        $hash->{$_} = int(rand()*$pairs)+1;
    }
    [200, "OK", $hash];
}

$SPEC{noop} = {
    v => 1.1,
    summary => "Do nothing, return original argument",
    description => <<'_',


_
    args => {
        arg => {
            summary => 'Argument',
            schema => ['any'],
            pos => 0,
        },
    },
    features => {pure => 1},
};

sub noop {
    my %args = @_; # NO_VALIDATE_ARGS
    [200, "OK", $args{arg}];
}

$SPEC{test_completion} = {
    v => 1.1,
    summary => "Do nothing, return nothing",
    description => <<'_',

This function is used to test argument completion.

_
    args => {
        i1 => {
            schema => ['int*' => {min=>1, xmax=>100}],
        },
        i2 => {
            schema => ['int*' => {min=>1, max=>1000}],
        },
        f1 => {
            schema => ['float*' => {xmin=>1, xmax=>10}],
        },
        s1 => {
            schema => [str => {
                in=>[qw/apple apricot banana grape grapefruit/,
                     "red date", "red grape", "green grape",
                 ],
            }],
        },
        s2 => {
            schema => 'str',
            completion => sub {
                my %args = @_;
                my $word = $args{word} // "";
                [ map {$word . $_} "a".."z" ],
            },
        },
        s3 => {
            schema => 'str',
            completion => sub { die },
        },
    },
    features => {pure => 1},
};
sub test_completion {
    # NO_VALIDATE_ARGS
    [200, "OK"];
}

$SPEC{sum} = {
    v => 1.1,
    summary => "Sum numbers in array",
    description => <<'_',

This function can be used to test passing nonscalar (array) arguments.

_
    args => {
        array => {
            summary => 'Array',
            schema  => ['array*', of => 'float*'],
            req     => 1,
            pos     => 0,
            greedy  => 1,
        },
        round => {
            summary => 'Whether to round result to integer',
            schema  => [bool => default => 0],
        },
    },
    examples => [
        {
            summary => 'First example',
            args    => {array=>[1, 2, 3]},
            status  => 200,
            result  => 6,
        },
        {
            summary => 'Second example, using argv',
            argv    => [qw/--round 1.1 2.1 3.1/],
            status  => 200,
            result  => 6,
        },
        {
            summary => 'Third example, invalid arguments',
            args    => {array=>[qw/a/]},
            status  => 400,
        },

        {
            summary   => 'Total numbers found in a file (4th example, bash)',
            src       => q(grep '[0-9]' file.txt | xargs sum),
            src_plang => 'bash',
        },
        {
            summary   => '2-dice roll (5th example, perl)',
            src       => <<'EOT',
my $res = sum(array=>[map {int(rand()*6+1)} 1..2]);
say $res->[2] >= 6 ? "high" : "low";
EOT
            src_plang => 'perl',
        },
    ],
    features => {},
};
sub sum {
    my %args = @_; # NO_VALIDATE_ARGS

    my $sum = 0;
    for (@{$args{array}}) {
        $sum += $_ if defined && looks_like_number($_);
    }
    $sum = int($sum) if $args{round};
    [200, "OK", $sum];
}

$SPEC{merge_hash} = {
    v => 1.1,
    summary => "Merge two hashes",
    description => <<'_',

This function can be used to test passing nonscalar (hash) arguments.

_
    args => {
        h1 => {
            summary => 'First hash (left-hand side)',
            schema => ['hash*'],
            req => 1,
            pos => 0,
        },
        h2 => {
            summary => 'First hash (right-hand side)',
            schema => ['hash*'],
            req => 1,
            pos => 1,
        },
    },
    result => {
        schema => 'hash*',
    },
    features => {},
    "_perinci.sub.wrapper.validate_args" => 0,
};
sub merge_hash {
    my %args = @_;
    my $h1 = $args{h1}; my $_sahv_dpath = []; my $arg_err; ((defined($h1)) ? 1 : (($arg_err //= (@$_sahv_dpath ? '@'.join("/",@$_sahv_dpath).": " : "") . "Required input not specified"),0)) && ((ref($h1) eq 'HASH') ? 1 : (($arg_err //= (@$_sahv_dpath ? '@'.join("/",@$_sahv_dpath).": " : "") . "Input is not of type hash"),0)); if ($arg_err) { return [400, "Invalid argument value for h1: $arg_err"] } # VALIDATE_ARG
    my $h2 = $args{h2}; ((defined($h2)) ? 1 : (($arg_err //= (@$_sahv_dpath ? '@'.join("/",@$_sahv_dpath).": " : "") . "Required input not specified"),0)) && ((ref($h2) eq 'HASH') ? 1 : (($arg_err //= (@$_sahv_dpath ? '@'.join("/",@$_sahv_dpath).": " : "") . "Input is not of type hash"),0)); if ($arg_err) { return [400, "Invalid argument value for h2: $arg_err"] } # VALIDATE_ARG

    [200, "OK", {%$h1, %$h2}];
}

$SPEC{test_validate_args} = {
    v => 1.1,
    summary => "Does nothing, only here to test # VALIDATE_ARGS",
    args => {
        a => {
            schema => "int",
        },
        b => {
            schema => [str => {min_len=>2}],
        },
        h1 => { # same as in merge_hash
            schema => 'hash',
        },
    },
    result => {
        schema => 'str*',
    },
    features => {},
    "_perinci.sub.wrapper.validate_args" => 0,
};
sub test_validate_args {
    my %args = @_; require Scalar::Util;my $_sahv_dpath = []; my $arg_err; if (exists($args{'a'})) { (!defined($args{'a'}) ? 1 :  ((Scalar::Util::looks_like_number($args{'a'}) =~ /^(?:1|2|9|10|4352)$/) ? 1 : (($arg_err //= (@$_sahv_dpath ? '@'.join("/",@$_sahv_dpath).": " : "") . "Input is not of type integer"),0))); if ($arg_err) { return [400, "Invalid argument value for a: $arg_err"] } }if (exists($args{'b'})) { (!defined($args{'b'}) ? 1 :  ((!ref($args{'b'})) ? 1 : (($arg_err //= (@$_sahv_dpath ? '@'.join("/",@$_sahv_dpath).": " : "") . "Input is not of type text"),0)) && ((length($args{'b'}) >= 2) ? 1 : (($arg_err //= (@$_sahv_dpath ? '@'.join("/",@$_sahv_dpath).": " : "") . "Length must be at least 2"),0))); if ($arg_err) { return [400, "Invalid argument value for b: $arg_err"] } }if (exists($args{'h1'})) { (!defined($args{'h1'}) ? 1 :  ((ref($args{'h1'}) eq 'HASH') ? 1 : (($arg_err //= (@$_sahv_dpath ? '@'.join("/",@$_sahv_dpath).": " : "") . "Input is not of type hash"),0))); if ($arg_err) { return [400, "Invalid argument value for h1: $arg_err"] } }# VALIDATE_ARGS
    [200];
}

$SPEC{undescribed_args} = {
    v => 1.1,
    summary => 'This function has several undescribed args',
    description => <<'_',

Originally added to see how peri-func-usage or Perinci::To::Text will display
the usage or documentation for this function.

_
    args => {
        arg1 => {},
        arg2 => {},
        arg3 => {},
        arg4 => {
            cmdline_aliases => {A=>{}},
        },
    },
};
sub undescribed_args {
    [200];
}

$SPEC{arg_default} = {
    v => 1.1,
    summary => 'Demonstrate argument default value from default and/or schema',
    args => {
        a => {
            summary => 'No defaults',
            schema  => ['int'],
        },
        b => {
            summary => 'Default from "default" property',
            default => 2,
            schema  => ['int'],
        },
        c => {
            summary => 'Default from schema',
            schema  => ['int', default => 3],
        },
        d => {
            summary => 'Default from "default" property as well as schema',
            description => <<'_',

"Default" property overrides default value from schema.

_
            default => 4,
            schema  => ['int', default=>-4],
        },
    },
};
sub arg_default {
    my %args = @_;
    [200, "OK", join("\n", map { "$_=" . ($args{$_} // "") } (qw/a b c d/))];
}

1;
# ABSTRACT: Example modules containing metadata and various example functions

__END__

=pod

=encoding UTF-8

=head1 NAME

Perinci::Examples - Example modules containing metadata and various example functions

=head1 VERSION

version 0.18

=head1 SYNOPSIS

 use Perinci::Examples qw(delay);
 delay();

=head1 DESCRIPTION

This module and its submodules contain an odd mix of various functions,
variables, and other code entities, along with their L<Rinci> metadata. Mostly
used for testing Rinci specification and the various L<Perinci> modules.

Example scripts are put in a separate distribution (see
L<Perinci::Examples::Bin>) to make dependencies for this distribution minimal
(e.g. not depending on L<Perinci::CmdLine>) since this example module(s) are
usually used in the tests of other modules.


{en_US 
A sample description

    verbatim
    line2

Another paragraph with I<bold>, I<italic> text.
}

=head1 FUNCTIONS


=head2 arg_default(%args) -> [status, msg, result, meta]

{en_US Demonstrate argument default value from default and/or schema}.

Arguments ('*' denotes required arguments):

=over 4

=item * B<a> => I<int>

{en_US Demonstrate argument default value from default and/or schema}.

=item * B<b> => I<int> (default: 2)

{en_US Demonstrate argument default value from default and/or schema}.

=item * B<c> => I<int> (default: 3)

{en_US Demonstrate argument default value from default and/or schema}.

=item * B<d> => I<int> (default: 4)

{en_US Demonstrate argument default value from default and/or schema}.

=back

Return value:

Returns an enveloped result (an array). First element (status) is an integer containing HTTP status code (200 means OK, 4xx caller error, 5xx function error). Second element (msg) is a string containing error message, or 'OK' if status is 200. Third element (result) is optional, the actual result. Fourth element (meta) is called result metadata and is optional, a hash that contains extra information.

=head2 call_gen_array(%args) -> [status, msg, result, meta]

{en_US Call gen_array()}.

{en_US 
This is to test nested call (e.g. Log::Any::For::Package).
}

Arguments ('*' denotes required arguments):

=over 4

=item * B<len>* => I<int> (default: 10)

{en_US Call gen_array()}.

{en_US 
This is to test nested call (e.g. Log::Any::For::Package).
}

=back

Return value:

Returns an enveloped result (an array). First element (status) is an integer containing HTTP status code (200 means OK, 4xx caller error, 5xx function error). Second element (msg) is a string containing error message, or 'OK' if status is 200. Third element (result) is optional, the actual result. Fourth element (meta) is called result metadata and is optional, a hash that contains extra information.

=head2 call_randlog(%args) -> [status, msg, result, meta]

{en_US Call randlog()}.

{en_US 
This is to test nested call (e.g. Log::Any::For::Package).
}

Arguments ('*' denotes required arguments):

=over 4

=item * B<max_level> => I<int> (default: 6)

{en_US Call randlog()}.

{en_US 
This is to test nested call (e.g. Log::Any::For::Package).
}

=item * B<min_level> => I<int> (default: 1)

{en_US Call randlog()}.

{en_US 
This is to test nested call (e.g. Log::Any::For::Package).
}

=item * B<n> => I<int> (default: 10)

{en_US Call randlog()}.

{en_US 
This is to test nested call (e.g. Log::Any::For::Package).
}

=back

Return value:

Returns an enveloped result (an array). First element (status) is an integer containing HTTP status code (200 means OK, 4xx caller error, 5xx function error). Second element (msg) is a string containing error message, or 'OK' if status is 200. Third element (result) is optional, the actual result. Fourth element (meta) is called result metadata and is optional, a hash that contains extra information.

=head2 delay(%args) -> [status, msg, result, meta]

{id_ID Tidur, defaultnya 10 detik}.

{idI<ID 
Dapat dipakai untuk menguji properti *time>limit*.
}

Arguments ('*' denotes required arguments):

=over 4

=item * B<n> => I<int> (default: 10)

{id_ID Tidur, defaultnya 10 detik}.

{idI<ID 
Dapat dipakai untuk menguji properti *time>limit*.
}

=item * B<per_second> => I<bool> (default: 0)

{id_ID Tidur, defaultnya 10 detik}.

{idI<ID 
Dapat dipakai untuk menguji properti *time>limit*.
}

=back

Return value:

Returns an enveloped result (an array). First element (status) is an integer containing HTTP status code (200 means OK, 4xx caller error, 5xx function error). Second element (msg) is a string containing error message, or 'OK' if status is 200. Third element (result) is optional, the actual result. Fourth element (meta) is called result metadata and is optional, a hash that contains extra information.

=head2 dies() -> [status, msg, result, meta]

{en_US Dies tragically}.

{en_US 
Can be used to test exception handling.
}

No arguments.

Return value:

Returns an enveloped result (an array). First element (status) is an integer containing HTTP status code (200 means OK, 4xx caller error, 5xx function error). Second element (msg) is a string containing error message, or 'OK' if status is 200. Third element (result) is optional, the actual result. Fourth element (meta) is called result metadata and is optional, a hash that contains extra information.

=head2 err(%args) -> [status, msg, result, meta]

{en_US Return error response}.

{en_US 
}

Arguments ('*' denotes required arguments):

=over 4

=item * B<code> => I<int> (default: 500)

{en_US Return error response}.

{en_US 
}

=back

Return value:

Returns an enveloped result (an array). First element (status) is an integer containing HTTP status code (200 means OK, 4xx caller error, 5xx function error). Second element (msg) is a string containing error message, or 'OK' if status is 200. Third element (result) is optional, the actual result. Fourth element (meta) is called result metadata and is optional, a hash that contains extra information.

=head2 gen_array(%args) -> [status, msg, result, meta]

{en_US Generate an array of specified length}.

{en_US 
Also tests result schema.
}

Arguments ('*' denotes required arguments):

=over 4

=item * B<len>* => I<int> (default: 10)

{en_US Generate an array of specified length}.

{en_US 
Also tests result schema.
}

=back

Return value:

Returns an enveloped result (an array). First element (status) is an integer containing HTTP status code (200 means OK, 4xx caller error, 5xx function error). Second element (msg) is a string containing error message, or 'OK' if status is 200. Third element (result) is optional, the actual result. Fourth element (meta) is called result metadata and is optional, a hash that contains extra information.

=head2 gen_hash(%args) -> [status, msg, result, meta]

{en_US Generate a hash with specified number of pairs}.

{en_US 
Also tests result schema.
}

Arguments ('*' denotes required arguments):

=over 4

=item * B<pairs> => I<int>

{en_US Generate a hash with specified number of pairs}.

{en_US 
Also tests result schema.
}

=back

Return value:

Returns an enveloped result (an array). First element (status) is an integer containing HTTP status code (200 means OK, 4xx caller error, 5xx function error). Second element (msg) is a string containing error message, or 'OK' if status is 200. Third element (result) is optional, the actual result. Fourth element (meta) is called result metadata and is optional, a hash that contains extra information.

=head2 merge_hash(%args) -> [status, msg, result, meta]

{en_US Merge two hashes}.

{en_US 
This function can be used to test passing nonscalar (hash) arguments.
}

Arguments ('*' denotes required arguments):

=over 4

=item * B<h1>* => I<hash>

{en_US Merge two hashes}.

{en_US 
This function can be used to test passing nonscalar (hash) arguments.
}

=item * B<h2>* => I<hash>

{en_US Merge two hashes}.

{en_US 
This function can be used to test passing nonscalar (hash) arguments.
}

=back

Return value:

Returns an enveloped result (an array). First element (status) is an integer containing HTTP status code (200 means OK, 4xx caller error, 5xx function error). Second element (msg) is a string containing error message, or 'OK' if status is 200. Third element (result) is optional, the actual result. Fourth element (meta) is called result metadata and is optional, a hash that contains extra information.

=head2 noop(%args) -> [status, msg, result, meta]

{en_US Do nothing, return original argument}.

{en_US 
}

This function is pure (produce no side effects).


Arguments ('*' denotes required arguments):

=over 4

=item * B<arg> => I<any>

{en_US Do nothing, return original argument}.

{en_US 
}

=back

Return value:

Returns an enveloped result (an array). First element (status) is an integer containing HTTP status code (200 means OK, 4xx caller error, 5xx function error). Second element (msg) is a string containing error message, or 'OK' if status is 200. Third element (result) is optional, the actual result. Fourth element (meta) is called result metadata and is optional, a hash that contains extra information.

=head2 randlog(%args) -> [status, msg, result, meta]

{en_US Produce some random Log::Any log messages}.

{en_US }

Arguments ('*' denotes required arguments):

=over 4

=item * B<max_level> => I<int> (default: 6)

{en_US Produce some random Log::Any log messages}.

{en_US }

=item * B<min_level> => I<int> (default: 1)

{en_US Produce some random Log::Any log messages}.

{en_US }

=item * B<n> => I<int> (default: 10)

{en_US Produce some random Log::Any log messages}.

{en_US }

=back

Return value:

Returns an enveloped result (an array). First element (status) is an integer containing HTTP status code (200 means OK, 4xx caller error, 5xx function error). Second element (msg) is a string containing error message, or 'OK' if status is 200. Third element (result) is optional, the actual result. Fourth element (meta) is called result metadata and is optional, a hash that contains extra information.

=head2 sum(%args) -> [status, msg, result, meta]

{en_US Sum numbers in array}.

Examples:

 sum(array => [1, 2, 3]); # -> 6

 sum(array => [1.1, 2.1, 3.1], round => 1); # -> 6

 sum(array => ["a"]); # ERROR 400

 sum();

 sum();

{en_US 
This function can be used to test passing nonscalar (array) arguments.
}

Arguments ('*' denotes required arguments):

=over 4

=item * B<array>* => I<array>

{en_US Sum numbers in array}.

{en_US 
This function can be used to test passing nonscalar (array) arguments.
}

=item * B<round> => I<bool> (default: 0)

{en_US Sum numbers in array}.

{en_US 
This function can be used to test passing nonscalar (array) arguments.
}

=back

Return value:

Returns an enveloped result (an array). First element (status) is an integer containing HTTP status code (200 means OK, 4xx caller error, 5xx function error). Second element (msg) is a string containing error message, or 'OK' if status is 200. Third element (result) is optional, the actual result. Fourth element (meta) is called result metadata and is optional, a hash that contains extra information.

=head2 test_completion(%args) -> [status, msg, result, meta]

{en_US Do nothing, return nothing}.

{en_US 
This function is used to test argument completion.
}

This function is pure (produce no side effects).


Arguments ('*' denotes required arguments):

=over 4

=item * B<f1> => I<float>

{en_US Do nothing, return nothing}.

{en_US 
This function is used to test argument completion.
}

=item * B<i1> => I<int>

{en_US Do nothing, return nothing}.

{en_US 
This function is used to test argument completion.
}

=item * B<i2> => I<int>

{en_US Do nothing, return nothing}.

{en_US 
This function is used to test argument completion.
}

=item * B<s1> => I<str>

{en_US Do nothing, return nothing}.

{en_US 
This function is used to test argument completion.
}

=item * B<s2> => I<str>

{en_US Do nothing, return nothing}.

{en_US 
This function is used to test argument completion.
}

=item * B<s3> => I<str>

{en_US Do nothing, return nothing}.

{en_US 
This function is used to test argument completion.
}

=back

Return value:

Returns an enveloped result (an array). First element (status) is an integer containing HTTP status code (200 means OK, 4xx caller error, 5xx function error). Second element (msg) is a string containing error message, or 'OK' if status is 200. Third element (result) is optional, the actual result. Fourth element (meta) is called result metadata and is optional, a hash that contains extra information.

=head2 test_validate_args(%args) -> [status, msg, result, meta]

{en_US Does nothing, only here to test # VALIDATE_ARGS}.

Arguments ('*' denotes required arguments):

=over 4

=item * B<a> => I<int>

{en_US Does nothing, only here to test # VALIDATE_ARGS}.

=item * B<b> => I<str>

{en_US Does nothing, only here to test # VALIDATE_ARGS}.

=item * B<h1> => I<hash>

{en_US Does nothing, only here to test # VALIDATE_ARGS}.

=back

Return value:

Returns an enveloped result (an array). First element (status) is an integer containing HTTP status code (200 means OK, 4xx caller error, 5xx function error). Second element (msg) is a string containing error message, or 'OK' if status is 200. Third element (result) is optional, the actual result. Fourth element (meta) is called result metadata and is optional, a hash that contains extra information.

=head2 undescribed_args(%args) -> [status, msg, result, meta]

{en_US This function has several undescribed args}.

{en_US 
Originally added to see how peri-func-usage or Perinci::To::Text will display
the usage or documentation for this function.
}

Arguments ('*' denotes required arguments):

=over 4

=item * B<arg1> => I<any>

{en_US This function has several undescribed args}.

{en_US 
Originally added to see how peri-func-usage or Perinci::To::Text will display
the usage or documentation for this function.
}

=item * B<arg2> => I<any>

{en_US This function has several undescribed args}.

{en_US 
Originally added to see how peri-func-usage or Perinci::To::Text will display
the usage or documentation for this function.
}

=item * B<arg3> => I<any>

{en_US This function has several undescribed args}.

{en_US 
Originally added to see how peri-func-usage or Perinci::To::Text will display
the usage or documentation for this function.
}

=item * B<arg4> => I<any>

{en_US This function has several undescribed args}.

{en_US 
Originally added to see how peri-func-usage or Perinci::To::Text will display
the usage or documentation for this function.
}

=back

Return value:

Returns an enveloped result (an array). First element (status) is an integer containing HTTP status code (200 means OK, 4xx caller error, 5xx function error). Second element (msg) is a string containing error message, or 'OK' if status is 200. Third element (result) is optional, the actual result. Fourth element (meta) is called result metadata and is optional, a hash that contains extra information.

=head1 SEE ALSO

L<Perinci>

L<Perinci::Examples::Bin>

=head1 HOMEPAGE

Please visit the project's homepage at L<https://metacpan.org/release/Perinci-Examples>.

=head1 SOURCE

Source repository is at L<https://github.com/sharyanto/perl-Perinci-Examples>.

=head1 BUGS

Please report any bugs or feature requests on the bugtracker website L<https://rt.cpan.org/Public/Dist/Display.html?Name=Perinci-Examples>

When submitting a bug or request, please include a test-file or a
patch to an existing test-file that illustrates the bug or desired
feature.

=head1 AUTHOR

Steven Haryanto <stevenharyanto@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Steven Haryanto.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
