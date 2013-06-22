package Nephia::Lite;
use 5.008005;
use strict;
use warnings;
use utf8;

use Nephia ();
use Exporter;
use Carp;
use Encode;
use Text::MicroTemplate;

our $VERSION = "0.03";

sub import {
    my $caller = caller;

    {
        no strict 'refs';
        for my $func (grep { $_ =~ /^[a-z]/ && $_ ne 'import' && $_ ne 'run' } keys %{'Nephia::'}) {
            *{$caller.'::'.$func} = *{'Nephia::'.$func};
        }
        *{$caller.'::_run'} = *{'Nephia::run'};
        *{$caller.'::run'} = \&run;
    }
}

sub run(&@) {
    my $coderef = shift;
    my $caller = caller;


    {
        no strict 'refs';
        my $renderer = ${$caller.'RENDERER'};
        if ( !$renderer ) {
             my $content = _read_section_data($caller);
            $renderer = ${$caller.'::RENDERER'} ||= _build($content) if $content;
        }

        &Nephia::Core::_path (
            '/' => sub {
                my $req = $_[0];
                my $param = $_[1];

                no strict qw[ refs subs ];
                no warnings qw[ redefine ];
                local *{$caller."::req"} = sub{ $req };
                local *{$caller."::param"} = sub{ $param };

                my $res = $coderef->(@_);

                if ($renderer) {
                    my $charset = $res->{charset} || $Nephia::Core::CHARSET;
                    $res = &{$caller.'::res'} (sub {
                        content_type( "text/html; charset=$charset" );
                        my $body = encode( $charset, $renderer->($res) );
                        body( $body );
                    });
                }

                return $res;
            },
            undef,
            $caller
        );
    }

    my $app = $caller->_run();

    return $app;
}

sub _read_section_data {
    my $pkg = shift;
    my $content;
    {
        no strict 'refs';
        my $d = \*{$pkg.'::DATA'};
        {
            no warnings 'unopened';
            $content = join '', <$d>;
        }
        $content =~ s/^.*\n__DATA__\n/\n/s;
        $content =~ s/__END__\n.*$/\n/s;
    }
    return $content;
}

sub _build {
    if (my $data = shift) {
        my @splited_data = split /\$/, $data;

        shift @splited_data;
        my @already_vars;
        for my $segment (@splited_data) {
            next if $segment =~ /_/;
            my @words = split /(?![a-zA-Z0-9_])/, $segment;
            my $var_name = shift @words;
            next if grep { $var_name eq $_ } @already_vars;
            push @already_vars, $var_name;
            $data = "? my \$$var_name = \$_[0]->{$var_name};\n".$data;
        }

        my $f = Text::MicroTemplate::build_mt(decode_utf8 $data);;

        return $f;
    }

    croak "could not find template content in __DATA__ section";
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

