package Nephia::Lite;
use 5.008005;
use strict;
use warnings;

use parent qw/Nephia/;
use Data::Section::Simple;
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

    {
        no strict 'refs';
        &{$caller."::path"} (
            '/' => sub {
                my $res = $coderef->(@_);
                $res->{template} ||= 'DATA';
                return $res;
            }
        );
    }

    my $app = $caller->run();

    if (!exists $Nephia::Core::CONFIG->{view}) {
        $Nephia::Core::VIEW = Nephia::Lite::View->new(package => $caller);
    }

    return $app;
}

package Nephia::Lite::View {
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
}

package Nephia::Lite::View::MicroTemplate {

    sub new {
        my ($class, %opts) = @_;
        my $mt = Text::MicroTemplate::DataSection::ForNephia->new(%opts);
        bless { mt => $mt }, $class;
    }

    sub render {
        my ($self, @params) = @_;
        $self->{mt}->render_file(@params);
    }
}

package Text::MicroTemplate::DataSection::ForNephia {
    use parent qw/Text::MicroTemplate::File/;
    use Encode;
    use Carp;

    sub new {
        my $self = shift->SUPER::new(@_);
        $self->{package} ||= scalar caller;
        $self->{template} = $self->_read_section_data();

        $self;
    }

    sub _read_section_data {
        my $self = shift;
        my $content;
        {
            no strict 'refs';
            my $d = \*{$self->{package}.'::DATA'};
            $content = join '', <$d>;
            $content =~ s/^.*\n__DATA__\n/\n/s;
            $content =~ s/__END__\n.*$/\n/s;
        }
        return $content;
    }


    sub build_file {
        my $self = shift;

        #if (my $e = $self->{cache}) {
        #    return $e;
        #}

        if (my $data = $self->{template}) {
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

            $self->{cache} = $f if $self->{use_cache};
            return $f;
        }

        croak "could not find template content in __DATA__ section";
    }

    sub render_mt {
        my $self = __PACKAGE__->new(package => shift);

        $self->render_file(@_);
    }
}

1;

__END__

=encoding utf-8

=head1 NAME

Nephia::Lite - mini and lite WAF. one file, once write, quickly render!

=head1 SYNOPSIS

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

=head1 DESCRIPTION

Nephia::Lite is minimum set of Nephia.

However, usable Nephia's feature and useful plugins.

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

