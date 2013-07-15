package Nephia::Lite;
use 5.008005;
use strict;
use warnings;
use utf8;

use parent 'Nephia';

our $VERSION = "0.03";

sub import {
    my ($class, %opts) = @_;
    my @plugins = ! $opts{plugins} ? () :
                  ref($opts{plugins}) eq 'ARRAY' ? @{$opts{plugins}} :
                  ( $opts{plugins} )
    ;

    push @plugins, 'Lite';

    my $caller = caller;
    Nephia::Core->export_to_level(1);

    @_ = @plugins;
    goto do { Nephia::Core->can('nephia_plugins') } if @plugins;
}

1;

__END__

=encoding utf-8

=head1 NAME

Nephia::Lite - mini and lite WAF. one file, once write, quickly render!

=head1 SYNOPSIS

in app.psgi :

    use Nephia::Lite;

    run {
        return {
            title => 'sample'
        }
    };

    __DATA__

    <html>
    <head>
    <title><?= $title ?></title>
    <body>
    <h1>Hello, <?= $title ?></h1>
    </body>
    </html>

and plackup

    plackup app.psgi

Open "http://localhost:5000" with your favorite browser.

Rendered Dynamic Pages in your display!

=head1 DESCRIPTION

Nephia::Lite is minimum set of Nephia.

However, usable Nephia's feature and useful plugins.

=head2 Lite flavor for nephia-setup - generate skeleton

    nephia-setup appname --flavor=Lite

This command generate skeleton psgi file with Nephia::Lite.

=head2 Rendering page with template

Nephia::Lite use L<Text::MicroTemplate>.

Write after __DATA__ in app.psgi.

=head2 JSON Output

Don't write __DATA__ and templates.

Nephia::Lite automatically recognize to you want to JSON.

    use Nephia::Lite;

    run {
        return {
            message => 'Hello! This is a My JSON!!!'
        };
    };

Output

    {
        'message' : 'Hello! This is a My JSON!!!'
    }

=head2 Submapped Nephia::Lite application on Nephia

Your Nephia app can wrap Nephia::Lite app.

app.psgi

    use Nephia;

    path '/' => sub {
        location => 'index'
    };

    path '/subapp' => 'LiteApp';

LiteApp.pm

    package LiteApp;
    use Nephia::Lite;

    run {
        return {
            title => 'a little app'
        };
    };

    1;

    __DATA__

    <!DOCTYPE html>
    <html>
    <head>
      <title><?= $title ?></title>
    </head>
    <body>
      <h1><?= $title ?></h1>
    </body>
    </html>

LiteApp's root mapped to '/subapp'

=head2 Other features

Use can Nephia's features and plugins.

Ex. redirect, header, validate(L<Nephia::Plugin::Data::Validator>) and other DSLs.

But cannot use Nephia Views yet.

=head1 SEE ALSO

L<Nephia>

L<Text::MicroTemplate>

=head1 LICENSE

Copyright (C) macopy.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

macopy E<lt>macopy[attttttt]cpan.comE<gt>

=cut

