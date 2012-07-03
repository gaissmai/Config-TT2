package Config::TT;

use strict;
use warnings;
use Template::Config;
use Scalar::Util qw(blessed);

=head1 NAME

Config::TT - Config files

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use Config::TT;

    my $foo = Config::TT->new();
    ...

=head1 METHODS

=head2 new

=cut

sub new {
    my $class = shift;
    my $self = bless {}, $class;

    # build the Template::Context object
    my $params = defined( $_[0] ) && ref( $_[0] ) eq 'HASH' ? shift : {@_};

    # DEFAULTS:
    my $defaults = {
        STRICT     => 1,    # croak on undefined vars
        CACHE_SIZE => 0,    # don't cache the config file
        ABSOLUTE   => 1,    # don't cache the config file
    };

    my $ctx = Template::Config->context(%$defaults, %$params);

    # setter
    $self->context($ctx);

    return $self;
}

=head2 context

setter/getter for Template::Context object

=cut

sub context {
    my ($self, $ctx) = @_;
    $self->{ctx} = $ctx if defined $ctx;
    return $self->{ctx};
}

=head2 process

=cut

sub process {
    my $self = shift;
    my ( $template, $vars ) = @_;

    my $ctx = $self->{ctx};

    # HACK
    # delete predefined global slot
    delete $ctx->stash->{global};

    # process template
    $ctx->process($template, $vars);

    # HACK
    # delete component slot
    delete $ctx->stash->{component} if blessed $ctx->stash->{component};
    delete $ctx->stash->{component} if not defined $ctx->stash->{component};

    # copy Template::Stash and ...
    my $stash = Template::Config->stash();

    # HACK
    # delete predefined global slot and component slot
    delete $stash->{global};

    $stash->update($ctx->stash);

    # ... delete all private keys, coderefs and other internals
    foreach my $key ( keys %$stash ) {
        delete $stash->{$key} if $key =~ m/^[._]/;
        delete $stash->{$key} if ref $stash->{$key} eq 'CODE';
    }

    return $stash;
}

=head1 AUTHOR

Karl Gaissmaier, C<< <gaissmai at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-config-tt at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Config-TT>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Config::TT


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Config-TT>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Config-TT>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Config-TT>

=item * Search CPAN

L<http://search.cpan.org/dist/Config-TT/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2012 Karl Gaissmaier.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1;    # End of Config::TT

# vim: sw=4
