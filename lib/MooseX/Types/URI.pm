#!/usr/bin/perl

package MooseX::Types::URI;

use strict;
use warnings;

our $VERSION = "0.01";

use Scalar::Util qw(blessed);

use URI;
use URI::file;
use URI::data;
use URI::WithBase;
use URI::FromHash qw(uri);

use Moose::Util::TypeConstraints;

use MooseX::Types::Path::Class;

use namespace::clean;

use MooseX::Types -declare => [qw(Uri _UriWithBase _Uri FileUri DataUri)];

my $uri = Moose::Meta::TypeConstraint->new(
    name   => Uri,
    parent => Moose::Meta::TypeConstraint::Union->new(
        name => join("|", _Uri, _UriWithBase),
        type_constraints => [
            class_type( _Uri,         { class => "URI" } ),
            class_type( _UriWithBase, { class => "URI::WithBase" } ),
        ],
    ),
    optimized => sub {
        local $@;
        blessed($_[0]) && ( $_[0]->isa("URI") || $_[0]->isa("URI::WithBase") )
    },
);

register_type_constraint($uri);

coerce( _Uri,
    from Str                 => via { URI->new($_) },
    from "Path::Class::File" => via { URI::file->new($_) },
    from "Path::Class::Dir"  => via { URI::file->new($_) },
    from ScalarRef           => via { my $u = URI->new("data:"); $u->data($$_); $u },
    from HashRef             => via { uri(%$_) },
);

class_type FileUri, { class => "URI::file", parent => $uri };

coerce( FileUri,
    from Str                 => via { URI::file->new($_) },
    from "Path::Class::File" => via { URI::file->new($_) },
    from "Path::Class::Dir"  => via { URI::file->new($_) },
);

subtype DataUri, as _Uri, where {
    if ( my $scheme = $_->scheme ) {
        return $scheme eq 'data';
    } else {
        return undef;
    }
};

coerce( DataUri,
    from Str       => via { my $u = URI->new("data:"); $u->data($_);  $u },
    from ScalarRef => via { my $u = URI->new("data:"); $u->data($$_); $u },
);

__PACKAGE__

__END__

=pod

=head1 NAME

MooseX::Types::URI - L<URI> related types and coercions for Moose

=head1 SYNOPSIS

	use MooseX::Types::URI qw(Uri FileUri DataUri);

=head1 DESCRIPTION

=head1 TYPES

The types are with C<ucfirst> naming convention so that they don't mask the
L<URI> class.

=over 4

=item Uri

Either L<URI> or L<URI::WithBase>

Coerces from C<Str> via L<URI/new>.

Coerces from L<Path::Class::File> and L<Path::Class::Dir> via L<URI::file/new>.

Coerces from C<ScalarRef> via L<URI::data/new>.

Coerces from C<HashRef> using L<URI::FromHash>.

=item DataUri

A URI whose scheme is C<data>.

Coerces from C<Str> and C<ScalarRef> via L<URI::data/new>.

=item FileUri

A L<URI::file> class type.

Has coercions from C<Str>, L<Path::Class::File> and L<Path::Class::Dir> via L<URI::file/new>

=back

=head1 TODO

Think about L<Path::Resource> integration of some sort

=cut


