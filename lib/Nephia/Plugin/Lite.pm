package Nephia::Plugin::Lite;
use 5.008005;
use strict;
use warnings;
use utf8;

use Carp;
use Encode;
use Text::MicroTemplate;
use Nephia::Core ();
use Nephia::GlobalVars;

our $VERSION = "0.04";
our $APP_CLASS;
our $ORIGIN_RUN;

our @EXPORT = qw/run/;

sub load {
    my ($class, $app) = @_;
    $APP_CLASS = $app;
    $ORIGIN_RUN = $APP_CLASS->can('run');
}

sub run (&@) {
    my $coderef = shift;
    my $caller = caller;

    {
        no strict 'refs';
        my $renderer = ${$caller.'RENDERER'};
        if ( !$renderer ) {
             my $content = _read_section_data($caller);
            $renderer = ${$caller.'::RENDERER'} ||= build_template($content) if $content;
        }

        Nephia::Core::_path(
            '/' => sub {
                my $req = $_[0];
                my $param = $_[1];

                no strict qw[ refs subs ];
                no warnings qw[ redefine ];
                local *{$caller."::req"} = sub{ $req };
                local *{$caller."::param"} = sub{ $param };

                my $res = $coderef->(@_);

                if ($renderer) {
                    my $charset = $res->{charset} || Nephia::GlobalVars->get('charset');
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

    my $app = $ORIGIN_RUN->($caller);

    return $app;
};

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

sub build_template {
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

    use Nephia plugins => [qw/Lite/];

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

=head1 DESCRIPTION

Nephia::Plugin::Lite is Nephia::Lite plugin version.

=head1 SEE ALSO

L<Nephia>

L<Nephia::Lite>

L<Text::MicroTemplate>

=head1 LICENSE

Copyright (C) macopy.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

macopy E<lt>macopy[attttttt]cpan.comE<gt>

=cut
