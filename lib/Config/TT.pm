package Config::TT;

use strict;
use warnings;

use Template;
use Carp qw(carp);

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

    # params as HASH or HASHREF?
    my $params = defined( $_[0] ) && ref( $_[0] ) eq 'HASH' ? shift : {@_};

    #
    # Warn for unsupported Template and Template::Service params.
    # Our entry level is Template::Context, see Template::Manual::Internals
    #
    my @unsupported = qw(
      PRE_PROCESS
      PROCESS
      POST_PROCESS
      WRAPPER
      AUTO_RESET
      OUTPUT
      OUTPUT_PATH
      ERROR
      ERRORS
    );

    foreach my $unsupported (@unsupported) {
        carp "Option '$unsupported' not supported\n"
          if exists $params->{$unsupported};
    }

    #
    # DEFAULTS, see Template::Manual::Config
    #
    my $defaults = {
        PRE_CHOMP   => 1,
        POST_CHOMP  => 1,
        TRIM        => 1,
        STRICT      => 1,
        CACHE_SIZE  => 0,
        ABSOLUTE    => 1,
        RELATIVE    => 1,
        INTERPLOATE => 0,
        EVAL_PERL   => 0,
        RAW_PERL    => 0,
        RECURSION   => 0,
    };

    # override defaults by params
    my $self = bless { params => { %$defaults, %$params } }, $class;
    return $self->_build;
}

=head2 process

=cut

sub process {
    my ( $self, $template, $vars ) = @_;

    my $ctx = $self->{CONTEXT};

    #
    # processing template from Template::Context level and NOT
    # from Template::Service level to get the stash back
    #
    my $output = $ctx->process($template, $vars);

    # remove initial stash keys like _STRICT, _DEBUG, ...
    $self->_purge_stash($ctx->stash);

    return wantarray ? ( $ctx->stash, $output ) : $ctx->stash;
}

sub _build {
    my $self = shift;

    # our entry level is Template::Context, use Template method chain
    $self->{CONTEXT} = Template->new( $self->{params} )->service->context;

    return $self;
}

sub _purge_stash {
    my ($self, $stash) = @_;

    # vanilla stash for these params, use Template method chain
    my $vanilla_stash =
      Template->new( $self->{params} )->service->context->stash;

    # TODO
    # ... delete all vanilla keys from stash

}

=head1 LIMITATIONS

Due to an design error in TT2 version 2.24 and before you can't use the toplevel variable 'component' in your config files. Maybe this will get fixed in later releases of TT2.

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
