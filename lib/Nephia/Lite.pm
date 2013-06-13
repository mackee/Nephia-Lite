package Nephia::Lite;
use 5.008005;
use strict;
use warnings;

use parent qw/Nephia/;
use Exporter;

our $VERSION = "0.01";

sub import {
    my $caller = caller;
    {
        no strict 'refs';
        for my $func (grep { $_ =~ /^[a-z]/ && $_ ne 'import' } keys %{'Nephia::'}) {
            *{$caller.'::'.$func} = *{'Nephia::'.$func};
        }
        *{$caller.'::to_app'} = \&to_app;
    }
}

sub to_app(&@) {
    my $coderef = shift;
    my $caller = caller;

    my $content = Nephia::Lite::Util::DataSection->read_section_data($caller);

    {
        no strict 'refs';
        &{$caller."::path"} (
            '/' => sub {
                my $res = $coderef->(@_);
                $res->{template} ||= 'DATA' if $content;
                return $res;
            }
        );
    }

    my $app = $caller->run();

    if (!exists $Nephia::Core::CONFIG->{view}) {
        $Nephia::Core::VIEW =
            Nephia::Lite::View->new(
                package => $caller,
                '_content' => $content
            );
    }

    return $app;
}

package Nephia::Lite::Util::DataSection;

sub read_section_data {
    my $class = shift;
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

package Nephia::Lite::View;

use Nephia::ClassLoader;

sub new {
    my ($class, %opts) = @_;
    my $subclass = 'Nephia::Lite::View::MicroTemplate';
    if (exists $opts{class}) {
        $subclass = join '::', 'Nephia::View', delete $opts{class};
        Nephia::ClassLoader->load($subclass);
    }
    return $subclass->new(%opts);
}

package Nephia::Lite::View::MicroTemplate;

sub new {
    my ($class, %opts) = @_;

    my $mt = Text::MicroTemplate::DataSection::ForNephia->new(%opts);
    bless { mt => $mt }, $class;
}

sub render {
    my ($self, @params) = @_;
    $self->{mt}->render_file(@params);
}

package Text::MicroTemplate::DataSection::ForNephia;

use parent qw/Text::MicroTemplate::File/;
use Encode;
use Carp;

sub new {
    my $self = shift->SUPER::new(@_);
    my $pkg = $self->{package} ||= scalar caller;

    $self;
}


sub build_file {
    my $self = shift;

    if (my $e = $self->{cache}->{'DATA'}) {
        return $e;
    }

    if (my $data = $self->{_content}) {
        my @splited_data = split /\$/, $data;

        shift @splited_data;
        my @already_vars;
        for my $segment (@splited_data) {
            next if $segment =~ /_/;
            my @words = split /\ /, $segment;
            my $var_name = shift @words;
            next if grep { $var_name eq $_ } @already_vars;
            push @already_vars, $var_name;
            $data = "? my \$$var_name = \$_[0]->{$var_name};\n".$data;
        }

        $self->parse(decode_utf8 $data);

        local $Text::MicroTemplate::_mt_setter = 'my $_mt = shift;';
        my $f = $self->build();

        $self->{cache}->{'DATA'} = $f if $self->{use_cache};
        return $f;
    }

    croak "could not find template content in __DATA__ section";
}

sub render_mt {
    my $self = __PACKAGE__->new(package => shift);

    $self->render_file(@_);
}

1;

__END__

=encoding utf-8

=head1 NAME

Nephia::Lite - mini and lite WAF. one file, once write, quickly render!

=head1 SYNOPSIS

in app.psgi :

    use Nephia::Lite;

    to_app {
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

=head2 Rendering page with template

Nephia::Lite used L<Text::MicroTemplate>.

Write after __DATA__ in app.psgi.

=head2 JSON Output

Don't write __DATA__ and templates.

Nephia::Lite automatically recognize to you want to JSON.

    use Nephia::Lite;

    to_app {
        return {
            message => 'Hello! This is a My JSON!!!'
        };
    };

Output

    {
        'message' : 'Hello! This is a My JSON!!!'
    }

=head2 Other features

Use can Nephia's features and plugins.

Ex. redirect, header, validate(L<Nephia::Plugin::Data::Validater>) and other DSLs.

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

