package Nephia::Lite::Xslate;
use 5.008005;
use strict;
use warnings;
use utf8;

use parent 'Nephia';

sub import {
    my ($class, %opts) = @_;
    my @plugins = ! $opts{plugins} ? () :
                  ref($opts{plugins}) eq 'ARRAY' ? @{$opts{plugins}} :
                  ( $opts{plugins} )
    ;

    push @plugins, 'Lite::Xslate';

    my $caller = caller;
    Nephia::Core->export_to_level(1);

    @_ = @plugins;
    goto do { Nephia::Core->can('nephia_plugins') } if @plugins;
}

1;

__END__

=encoding utf-8

=head1 NAME

Nephia::Lite::Xslate - Nephia::Lite with Text::Xslate

=head1 SYNOPSIS

in app.psgi :

    use Nephia::Lite::Xslate;

    run {
        return {
            title => 'sample'
        }
    };

    __DATA__

    <html>
    <head>
    <title><: $title :></title>
    <body>
    <h1>Hello, <: $title :></h1>
    </body>
    </html>

=head1 DESCRIPTION

Nephia::Lite is minimum set of Nephia.

However, usable Nephia's feature and useful plugins.

=head2 Lite::Xslate flavor for nephia-setup - generate skeleton

    nephia-setup appname --flavor=Lite::Xslate

This command generate skeleton psgi file with Nephia::Lite.

=head2 Rendering page with template

Nephia::Lite::Xslate use L<Text::Xslate>.

Write after __DATA__ in app.psgi.

=head1 SEE ALSO

L<Nephia>

L<Text::Xslate>

=head1 LICENSE

Copyright (C) macopy.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

macopy E<lt>macopy[attttttt]cpan.comE<gt>

=cut

