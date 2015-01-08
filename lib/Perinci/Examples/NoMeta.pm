package Perinci::Examples::NoMeta;

# This is a sample of a "traditional" Perl module, with no metadata or enveloped
# result.

use 5.010;
use strict;
use warnings;

our $Var1 = 1;

our $VERSION = '0.41'; # VERSION
our $DATE = '2014-11-12'; # DATE

sub pyth($$) {
    my ($a, $b) = @_;
    ($a*$a + $b*$b)**0.5;
}

sub gen_array {
    my ($len) = @_;
    $len //= 10;
    my @res;
    for (1..$len) { push @res, int(rand $len)+1 }
    \@res;
}

1;
#ABSTRACT: Example of module without any metadata

__END__

=pod

=encoding UTF-8

=head1 NAME

Perinci::Examples::NoMeta - Example of module without any metadata

=head1 VERSION

This document describes version 0.41 of Perinci::Examples::NoMeta (from Perl distribution Perinci-Examples), released on 2014-11-12.

=for Pod::Coverage .*

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
