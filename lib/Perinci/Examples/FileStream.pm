package Perinci::Examples::FileStream;

our $DATE = '2014-10-30'; # DATE
our $VERSION = '0.39'; # VERSION

use 5.010;
use strict;
use warnings;

use Fcntl qw(:DEFAULT);

our %SPEC;

$SPEC{':package'} = {
    v => 1.1,
    summary => 'Examples for reading/writing files',
    description => <<'_',

The functions in this package demos streaming input and output.

The functions are separated into this module because these functions read/write
files on the filesystem and might potentially be dangerous if
`Perinci::Examples` is exposed to the network by accident.

See also `Perinci::Examples::FilePartial` which uses partial technique instead
of streaming.

_
};

$SPEC{read_file} = {
    v => 1.1,
    args => {
        path => {schema=>'str*', req=>1, pos=>0},
    },
    result => {schema=>'buf*', stream=>1},
};
sub read_file {
    my %args = @_; my $_sahv_dpath = []; my $arg_err; if (exists($args{'path'})) { ((defined($args{'path'})) ? 1 : (($arg_err //= (@$_sahv_dpath ? '@'.join("/",@$_sahv_dpath).": " : "") . "Required input not specified"),0)) && ((!ref($args{'path'})) ? 1 : (($arg_err //= (@$_sahv_dpath ? '@'.join("/",@$_sahv_dpath).": " : "") . "Input is not of type text"),0)); if ($arg_err) { return [400, "Invalid argument value for path: $arg_err"] } }if (!exists($args{'path'})) { return [400, "Missing argument: path"] } # VALIDATE_ARGS

    my $path = $args{path};
    (-f $path) or return [404, "No such file '$path'"];

    open my($fh), "<", $path or return [500, "Can't open '$path': $!"];

    [200, "OK", $fh, {stream=>1}];
}

$SPEC{write_file} = {
    v => 1.1,
    description => <<'_',

Overwrites existing file.

_
    args => {
        path => {schema=>'str*', req=>1, pos=>0},
        content => {schema=>'buf*', req=>1, pos=>1, stream=>1,
                    cmdline_src=>'stdin_or_files'},
    },
};
sub write_file {
    my %args = @_; my $_sahv_dpath = []; my $arg_err; if (exists($args{'content'})) { ((defined($args{'content'})) ? 1 : (($arg_err //= (@$_sahv_dpath ? '@'.join("/",@$_sahv_dpath).": " : "") . "Required input not specified"),0)) && ((!ref($args{'content'})) ? 1 : (($arg_err //= (@$_sahv_dpath ? '@'.join("/",@$_sahv_dpath).": " : "") . "Input is not of type buffer"),0)); if ($arg_err) { return [400, "Invalid argument value for content: $arg_err"] } }if (!exists($args{'content'})) { return [400, "Missing argument: content"] } if (exists($args{'path'})) { ((defined($args{'path'})) ? 1 : (($arg_err //= (@$_sahv_dpath ? '@'.join("/",@$_sahv_dpath).": " : "") . "Required input not specified"),0)) && ((!ref($args{'path'})) ? 1 : (($arg_err //= (@$_sahv_dpath ? '@'.join("/",@$_sahv_dpath).": " : "") . "Input is not of type text"),0)); if ($arg_err) { return [400, "Invalid argument value for path: $arg_err"] } }if (!exists($args{'path'})) { return [400, "Missing argument: path"] } # VALIDATE_ARGS

    my $path = $args{path};

    open my($fh), ">", $path
        or return [500, "Can't open '$path' for writing: $!"];
    my $content = $args{content};
    my $written = 0;
    if (ref($content)) {
        my $fh = $content;
        local $/ = \(64*1024);
        while (<$fh>) { print $fh $_; $written += length($_) }
    } else {
        print $fh $content;
        $written += length($content);
    }

    [200, "Wrote $written byte(s)"];
}

$SPEC{append_file} = {
    v => 1.1,
    description => <<'_',

_
    args => {
        path => {schema=>'str*', req=>1, pos=>0},
        content => {schema=>'buf*', req=>1, pos=>1, stream=>1,
                    cmdline_src=>'stdin_or_files'},
    },
};
sub append_file {
    my %args = @_; my $_sahv_dpath = []; my $arg_err; if (exists($args{'content'})) { ((defined($args{'content'})) ? 1 : (($arg_err //= (@$_sahv_dpath ? '@'.join("/",@$_sahv_dpath).": " : "") . "Required input not specified"),0)) && ((!ref($args{'content'})) ? 1 : (($arg_err //= (@$_sahv_dpath ? '@'.join("/",@$_sahv_dpath).": " : "") . "Input is not of type buffer"),0)); if ($arg_err) { return [400, "Invalid argument value for content: $arg_err"] } }if (!exists($args{'content'})) { return [400, "Missing argument: content"] } if (exists($args{'path'})) { ((defined($args{'path'})) ? 1 : (($arg_err //= (@$_sahv_dpath ? '@'.join("/",@$_sahv_dpath).": " : "") . "Required input not specified"),0)) && ((!ref($args{'path'})) ? 1 : (($arg_err //= (@$_sahv_dpath ? '@'.join("/",@$_sahv_dpath).": " : "") . "Input is not of type text"),0)); if ($arg_err) { return [400, "Invalid argument value for path: $arg_err"] } }if (!exists($args{'path'})) { return [400, "Missing argument: path"] } # VALIDATE_ARGS

    my $path = $args{path};

    open my($fh), ">>", $path
        or return [500, "Can't open '$path' for writing: $!"];
    my $content = $args{content};
    my $written = 0;
    if (ref($content)) {
        my $fh = $content;
        local $/ = \(64*1024);
        while (<$fh>) { print $fh $_; $written += length($_) }
    } else {
        print $fh $content;
        $written += length($content);
    }

    [200, "Appended $written byte(s)"];
}

1;
# ABSTRACT: Examples for reading/writing files (using streaming result)

__END__

=pod

=encoding UTF-8

=head1 NAME

Perinci::Examples::FileStream - Examples for reading/writing files (using streaming result)

=head1 VERSION

This document describes version 0.39 of Perinci::Examples::FileStream (from Perl distribution Perinci-Examples), released on 2014-10-30.

=head1 DESCRIPTION


The functions in this package demos streaming input and output.

The functions are separated into this module because these functions read/write
files on the filesystem and might potentially be dangerous if
C<Perinci::Examples> is exposed to the network by accident.

See also C<Perinci::Examples::FilePartial> which uses partial technique instead
of streaming.

=head1 FUNCTIONS


=head2 append_file(%args) -> [status, msg, result, meta]

Arguments ('*' denotes required arguments):

=over 4

=item * B<content>* => I<buf>

=item * B<path>* => I<str>

=back

Return value:

Returns an enveloped result (an array).

First element (status) is an integer containing HTTP status code
(200 means OK, 4xx caller error, 5xx function error). Second element
(msg) is a string containing error message, or 'OK' if status is
200. Third element (result) is optional, the actual result. Fourth
element (meta) is called result metadata and is optional, a hash
that contains extra information.

 (any)


=head2 read_file(%args) -> [status, msg, result, meta]

Arguments ('*' denotes required arguments):

=over 4

=item * B<path>* => I<str>

=back

Return value:

Returns an enveloped result (an array).

First element (status) is an integer containing HTTP status code
(200 means OK, 4xx caller error, 5xx function error). Second element
(msg) is a string containing error message, or 'OK' if status is
200. Third element (result) is optional, the actual result. Fourth
element (meta) is called result metadata and is optional, a hash
that contains extra information.

 (buf)


=head2 write_file(%args) -> [status, msg, result, meta]

Overwrites existing file.

Arguments ('*' denotes required arguments):

=over 4

=item * B<content>* => I<buf>

=item * B<path>* => I<str>

=back

Return value:

Returns an enveloped result (an array).

First element (status) is an integer containing HTTP status code
(200 means OK, 4xx caller error, 5xx function error). Second element
(msg) is a string containing error message, or 'OK' if status is
200. Third element (result) is optional, the actual result. Fourth
element (meta) is called result metadata and is optional, a hash
that contains extra information.

 (any)

=head1 HOMEPAGE

Please visit the project's homepage at L<https://metacpan.org/release/Perinci-Examples>.

=head1 SOURCE

Source repository is at L<https://github.com/perlancar/perl-Perinci-Examples>.

=head1 BUGS

Please report any bugs or feature requests on the bugtracker website L<https://rt.cpan.org/Public/Dist/Display.html?Name=Perinci-Examples>

When submitting a bug or request, please include a test-file or a
patch to an existing test-file that illustrates the bug or desired
feature.

=head1 AUTHOR

perlancar <perlancar@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by perlancar@cpan.org.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
