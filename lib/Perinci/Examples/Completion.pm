package Perinci::Examples::Completion;

use 5.010;
use strict;
use warnings;
use experimental 'smartmatch';

our %SPEC;

our $VERSION = '0.27'; # VERSION
our $DATE = '2014-07-29'; # DATE

$SPEC{fruits} = {
    v => 1.1,
    args => {
        fruits => {
            schema => [array => of => 'str'],
            element_completion => sub {
                my %args = @_;
                # complete with unmentioned fruits
                my @allfruits = qw(apple apricot banana cherry durian);
                my $ary = $args{args}{fruits};
                my $res = [];
                for (@allfruits) {
                    push @$res, $_ unless $_ ~~ @$ary;
                }
                $res;
            },
            #req => 1,
            pos => 0,
            greedy => 1,
        },
    },
    description => <<'_',

Demonstrates completion of array elements.

_
};
sub fruits {
    [200];
}

1;
#ABSTRACT: More completion examples

__END__

=pod

=encoding UTF-8

=head1 NAME

Perinci::Examples::Completion - More completion examples

=head1 VERSION

This document describes version 0.27 of Perinci::Examples::Completion (from Perl distribution Perinci-Examples), released on 2014-07-29.

=head1 FUNCTIONS


=head2 fruits(%args) -> [status, msg, result, meta]

Demonstrates completion of array elements.

Arguments ('*' denotes required arguments):

=over 4

=item * B<fruits> => I<array>

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

=for Pod::Coverage .*

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

This software is copyright (c) 2014 by Steven Haryanto.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
