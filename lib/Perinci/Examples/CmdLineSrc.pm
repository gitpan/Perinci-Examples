package Perinci::Examples::CmdLineSrc;

our $DATE = '2014-10-11'; # DATE
our $VERSION = '0.33'; # VERSION

use 5.010;
use strict;
use warnings;

our %SPEC;

$SPEC{':package'} = {
    v => 1.1,
    summary => 'Examples for using cmdline_src function property',
};

$SPEC{cmdline_src_unknown} = {
    v => 1.1,
    summary => 'This function has arg with unknown cmdline_src value',
    args => {
        a1 => {schema=>'str*', cmdline_src=>'foo'},
    },
};
sub cmdline_src_unknown {
    my %args = @_;
    [200, "OK", "a1=$args{a1}"];
}

$SPEC{cmdline_src_invalid_arg_type} = {
    v => 1.1,
    summary => 'This function has non-str/non-array arg with cmdline_src',
    args => {
        a1 => {schema=>'int*', cmdline_src=>'stdin'},
    },
};
sub cmdline_src_invalid_arg_type {
    my %args = @_;
    [200, "OK", "a1=$args{a1}"];
}

$SPEC{cmdline_src_stdin_str} = {
    v => 1.1,
    summary => 'This function has arg with cmdline_src=stdin',
    args => {
        a1 => {schema=>'str*', cmdline_src=>'stdin'},
    },
};
sub cmdline_src_stdin_str {
    my %args = @_;
    [200, "OK", "a1=$args{a1}"];
}

$SPEC{cmdline_src_stdin_array} = {
    v => 1.1,
    summary => 'This function has arg with cmdline_src=stdin',
    args => {
        a1 => {schema=>'array*', cmdline_src=>'stdin'},
    },
};
sub cmdline_src_stdin_array {
    my %args = @_;
    [200, "OK", "a1=[".join(",",@{ $args{a1} })."]"];
}

$SPEC{cmdline_src_file} = {
    v => 1.1,
    summary => 'This function has args with cmdline_src _file',
    args => {
        a1 => {schema=>'str*', req=>1, cmdline_src=>'file'},
        a2 => {schema=>'array*', cmdline_src=>'file'},
    },
};
sub cmdline_src_file {
    my %args = @_;
    [200, "OK", "a1=$args{a1}\na2=[".join(",", @{ $args{a2} // [] })."]"];
}

$SPEC{cmdline_src_stdin_or_files_str} = {
    v => 1.1,
    summary => 'This function has str arg with cmdline_src=stdin_or_files',
    args => {
        a1 => {schema=>'str*', cmdline_src=>'stdin_or_files'},
    },
};
sub cmdline_src_stdin_or_files_str {
    my %args = @_;
    [200, "OK", "a1=$args{a1}"];
}

$SPEC{cmdline_src_stdin_or_files_array} = {
    v => 1.1,
    summary => 'This function has array arg with cmdline_src=stdin_or_files',
    args => {
        a1 => {schema=>'array*', cmdline_src=>'stdin_or_files'},
    },
};
sub cmdline_src_stdin_or_files_array {
    my %args = @_;
    [200, "OK", "a1=[".join(",",@{ $args{a1} })."]"];
}

$SPEC{cmdline_src_multi_stdin} = {
    v => 1.1,
    summary => 'This function has multiple args with cmdline_src stdin/stdin_or_files',
    args => {
        a1 => {schema=>'str*', cmdline_src=>'stdin_or_files'},
        a2 => {schema=>'str*', cmdline_src=>'stdin'},
    },
};
sub cmdline_src_multi_stdin {
    my %args = @_;
    [200, "OK", "a1=$args{a1}\na2=$args{a2}"];
}

$SPEC{cmdline_src_stdin_line} = {
    v => 1.1,
    summary => 'This function has a single stdin_line argument',
    args => {
        a1 => {schema=>'str*', req=>1, cmdline_src=>'stdin_line'},
        a2 => {schema=>'str*', req=>1},
    },
};
sub cmdline_src_stdin_line {
    my %args = @_;
    [200, "OK", "a1=$args{a1}\na2=$args{a2}"];
}

$SPEC{cmdline_src_multi_stdin_line} = {
    v => 1.1,
    summary => 'This function has several stdin_line arguments',
    description => <<'_',

And one also has its is_password property set to true.

_
    args => {
        a1 => {schema=>'str*', req=>1, cmdline_src=>'stdin_line'},
        a2 => {schema=>'str*', req=>1, cmdline_src=>'stdin_line', is_password=>1},
        a3 => {schema=>'str*', req=>1},
    },
};
sub cmdline_src_multi_stdin_line {
    my %args = @_;
    [200, "OK", "a1=$args{a1}\na2=$args{a2}\na3=$args{a3}"];
}

1;
# ABSTRACT: Examples for using cmdline_src function property

__END__

=pod

=encoding UTF-8

=head1 NAME

Perinci::Examples::CmdLineSrc - Examples for using cmdline_src function property

=head1 VERSION

This document describes version 0.33 of Perinci::Examples::CmdLineSrc (from Perl distribution Perinci-Examples), released on 2014-10-11.

=head1 FUNCTIONS


=head2 cmdline_src_file(%args) -> [status, msg, result, meta]

This function has args with cmdline_src _file.

Arguments ('*' denotes required arguments):

=over 4

=item * B<a1>* => I<str>

=item * B<a2> => I<array>

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


=head2 cmdline_src_invalid_arg_type(%args) -> [status, msg, result, meta]

This function has non-str/non-array arg with cmdline_src.

Arguments ('*' denotes required arguments):

=over 4

=item * B<a1> => I<int>

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


=head2 cmdline_src_multi_stdin(%args) -> [status, msg, result, meta]

This function has multiple args with cmdline_src stdin/stdin_or_files.

Arguments ('*' denotes required arguments):

=over 4

=item * B<a1> => I<str>

=item * B<a2> => I<str>

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


=head2 cmdline_src_multi_stdin_line(%args) -> [status, msg, result, meta]

This function has several stdin_line arguments.

And one also has its is_password property set to true.

Arguments ('*' denotes required arguments):

=over 4

=item * B<a1>* => I<str>

=item * B<a2>* => I<str>

=item * B<a3>* => I<str>

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


=head2 cmdline_src_stdin_array(%args) -> [status, msg, result, meta]

This function has arg with cmdline_src=stdin.

Arguments ('*' denotes required arguments):

=over 4

=item * B<a1> => I<array>

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


=head2 cmdline_src_stdin_line(%args) -> [status, msg, result, meta]

This function has a single stdin_line argument.

Arguments ('*' denotes required arguments):

=over 4

=item * B<a1>* => I<str>

=item * B<a2>* => I<str>

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


=head2 cmdline_src_stdin_or_files_array(%args) -> [status, msg, result, meta]

This function has array arg with cmdline_src=stdin_or_files.

Arguments ('*' denotes required arguments):

=over 4

=item * B<a1> => I<array>

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


=head2 cmdline_src_stdin_or_files_str(%args) -> [status, msg, result, meta]

This function has str arg with cmdline_src=stdin_or_files.

Arguments ('*' denotes required arguments):

=over 4

=item * B<a1> => I<str>

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


=head2 cmdline_src_stdin_str(%args) -> [status, msg, result, meta]

This function has arg with cmdline_src=stdin.

Arguments ('*' denotes required arguments):

=over 4

=item * B<a1> => I<str>

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


=head2 cmdline_src_unknown(%args) -> [status, msg, result, meta]

This function has arg with unknown cmdline_src value.

Arguments ('*' denotes required arguments):

=over 4

=item * B<a1> => I<str>

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

Source repository is at L<https://github.com/sharyanto/perl-Perinci-Examples>.

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
