package Perinci::Examples::File;

our $DATE = '2014-10-29'; # DATE
our $VERSION = '0.38'; # VERSION

use 5.010;
use strict;
use warnings;

use Fcntl qw(:DEFAULT);

our %SPEC;

$SPEC{':package'} = {
    v => 1.1,
    summary => 'Examples for reading/writing files',
    description => <<'_',

These functions support partial argument (`partial_arg` feature) and partial
result (`partial_res` feature). It also demos handling binary data

The functions are separated into this module because these functions read/write
files on the filesystem and might potentially be dangerous if
`Perinci::Examples` is exposed to the network by accident.

_
};

$SPEC{read_file} = {
    v => 1.1,
    args => {
        path => {schema=>'str*', req=>1, pos=>0},
    },
    features => {partial_res=>1},
    result => {schema=>'buf*'},
};
sub read_file {
    my %args = @_; my $_sahv_dpath = []; my $arg_err; if (exists($args{'path'})) { ((defined($args{'path'})) ? 1 : (($arg_err //= (@$_sahv_dpath ? '@'.join("/",@$_sahv_dpath).": " : "") . "Required input not specified"),0)) && ((!ref($args{'path'})) ? 1 : (($arg_err //= (@$_sahv_dpath ? '@'.join("/",@$_sahv_dpath).": " : "") . "Input is not of type text"),0)); if ($arg_err) { return [400, "Invalid argument value for path: $arg_err"] } }if (!exists($args{'path'})) { return [400, "Missing argument: path"] } # VALIDATE_ARGS

    my $path = $args{path};
    (-f $path) or return [404, "No such file '$path'"];
    my $size = (-s _);
    my $start = $args{-res_part_start} // 0;
    $start = 0     if $start < 0;
    $start = $size if $start > $size;
    my $len   = $args{-res_part_len} // $size;
    $len = $size-$start if $start+$len > $size;
    $len = 0            if $len < 0;

    my $is_partial = $start > 0 || $start+$len < $size;

    open my($fh), "<", $path or return [500, "Can't open '$path': $!"];
    seek $fh, $start, 0;
    my $data;
    read $fh, $data, $len;

    [$is_partial ? 206 : 200,
     $is_partial ? "Partial content" : "OK (whole content)",
     $data,
     {res_part_start=>$start, res_part_len=>$len}];
}

$SPEC{write_file} = {
    v => 1.1,
    args => {
        path => {schema=>'str*', req=>1, pos=>0},
        content => {schema=>'buf*', req=>1, pos=>1, partial=>1,
                    cmdline_src=>'stdin_or_files'},
    },
    features => {partial_arg=>1},
};
sub write_file {
    my %args = @_; my $_sahv_dpath = []; my $arg_err; if (exists($args{'content'})) { ((defined($args{'content'})) ? 1 : (($arg_err //= (@$_sahv_dpath ? '@'.join("/",@$_sahv_dpath).": " : "") . "Required input not specified"),0)) && ((!ref($args{'content'})) ? 1 : (($arg_err //= (@$_sahv_dpath ? '@'.join("/",@$_sahv_dpath).": " : "") . "Input is not of type buffer"),0)); if ($arg_err) { return [400, "Invalid argument value for content: $arg_err"] } }if (!exists($args{'content'})) { return [400, "Missing argument: content"] } if (exists($args{'path'})) { ((defined($args{'path'})) ? 1 : (($arg_err //= (@$_sahv_dpath ? '@'.join("/",@$_sahv_dpath).": " : "") . "Required input not specified"),0)) && ((!ref($args{'path'})) ? 1 : (($arg_err //= (@$_sahv_dpath ? '@'.join("/",@$_sahv_dpath).": " : "") . "Input is not of type text"),0)); if ($arg_err) { return [400, "Invalid argument value for path: $arg_err"] } }if (!exists($args{'path'})) { return [400, "Missing argument: path"] } # VALIDATE_ARGS

    my $path = $args{path};
    my $start = $args{"-arg_part_start/content"} // 0;

    sysopen my($fh), $path, O_WRONLY | O_CREAT
        or return [500, "Can't open '$path' for writing: $!"];
    sysseek $fh, $start, 0
        or return [500, "Can't seek to $start: $!"];
    my $written = syswrite $fh, $args{content};
    defined($written) or return [500, "Can't write content to '$path': $!"];

    [200, "Wrote $written byte(s) from position $start"];
}

$SPEC{append_file} = {
    v => 1.1,
    description => <<'_',

We don't set the `content` argument as `partial` because it's actually hard to
handle unordered/non-contiguous partial arguments if we open the file in append
mode. We'll need to put the whole argument to temporary file first, and then
append that temporary file to the target file.

_
    args => {
        path => {schema=>'str*', req=>1, pos=>0},
        content => {schema=>'buf*', req=>1, pos=>1,
                    cmdline_src=>'stdin_or_files'},
    },
};
sub append_file {
    my %args = @_; my $_sahv_dpath = []; my $arg_err; if (exists($args{'content'})) { ((defined($args{'content'})) ? 1 : (($arg_err //= (@$_sahv_dpath ? '@'.join("/",@$_sahv_dpath).": " : "") . "Required input not specified"),0)) && ((!ref($args{'content'})) ? 1 : (($arg_err //= (@$_sahv_dpath ? '@'.join("/",@$_sahv_dpath).": " : "") . "Input is not of type buffer"),0)); if ($arg_err) { return [400, "Invalid argument value for content: $arg_err"] } }if (!exists($args{'content'})) { return [400, "Missing argument: content"] } if (exists($args{'path'})) { ((defined($args{'path'})) ? 1 : (($arg_err //= (@$_sahv_dpath ? '@'.join("/",@$_sahv_dpath).": " : "") . "Required input not specified"),0)) && ((!ref($args{'path'})) ? 1 : (($arg_err //= (@$_sahv_dpath ? '@'.join("/",@$_sahv_dpath).": " : "") . "Input is not of type text"),0)); if ($arg_err) { return [400, "Invalid argument value for path: $arg_err"] } }if (!exists($args{'path'})) { return [400, "Missing argument: path"] } # VALIDATE_ARGS

    my $path = $args{path};

    sysopen my($fh), $path, O_WRONLY | O_APPEND | O_CREAT
        or return [500, "Can't open '$path' for appending: $!"];
    my $written = syswrite $fh, $args{content};
    defined($written) or return [500, "Can't append content to '$path': $!"];

    [200, "Appended $written byte(s)"];
}

1;
# ABSTRACT: Examples for reading/writing files (demos partial_arg/partial_res)

__END__

=pod

=encoding UTF-8

=head1 NAME

Perinci::Examples::File - Examples for reading/writing files (demos partial_arg/partial_res)

=head1 VERSION

This document describes version 0.38 of Perinci::Examples::File (from Perl distribution Perinci-Examples), released on 2014-10-29.

=head1 DESCRIPTION


These functions support partial argument (C<partial_arg> feature) and partial
result (C<partial_res> feature). It also demos handling binary data

The functions are separated into this module because these functions read/write
files on the filesystem and might potentially be dangerous if
C<Perinci::Examples> is exposed to the network by accident.

=head1 FUNCTIONS


=head2 append_file(%args) -> [status, msg, result, meta]

We don't set the C<content> argument as C<partial> because it's actually hard to
handle unordered/non-contiguous partial arguments if we open the file in append
mode. We'll need to put the whole argument to temporary file first, and then
append that temporary file to the target file.

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
