package Nephia::Lite;
use 5.008005;
use strict;
use warnings;

use parent qw/Nephia/;
use Data::Section::Simple;
use Sub::Prototype;
use Exporter;

*Nephia::export = \&Exporter::export;

our $VERSION = "0.01";

sub import {
    my $caller = caller;
    {
        no strict 'refs';
        *{$caller.'::to_app'} = \&to_app;
    }

    return Exporter::export_to_level('Nephia', 1, @_);
}

sub to_app(&@) {
    my $coderef = shift;
    my $caller = caller;

    {
        no strict 'refs';
        &{$caller."::path"} ('/' => $coderef);
    }

    my $app = $caller->run();

    if (!exists $Nephia::CONFIG->{view}) {
        $Nephia::VIEW = Nephia::Lite::View->new(package => $caller);
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

Nephia::Lite - It's new $module

=head1 SYNOPSIS

    use Nephia::Lite;

=head1 DESCRIPTION

Nephia::Lite is ...

=head1 LICENSE

Copyright (C) taniwaki-makoto.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

taniwaki-makoto E<lt>taniwaki-makoto@kayac.comE<gt>

=cut

