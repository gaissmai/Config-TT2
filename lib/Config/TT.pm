package Config::TT;

use strict;
use warnings;

use Template;
use Try::Tiny;
use Carp qw(croak);

=head1 NAME

Config::TT - A module for reading Template-Toolkit-style configuration files.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

    use Config::TT;
    my $tt_cfg = Config::TT->new($tt2_params);

    my $cfg_stash = $tt_cfg->process($template);
    my $cfg_stash = $tt_cfg->process( $template, $vars );
    my ( $cfg_stash, $output ) = $tt_cfg->process($template);

=head1 DESCRIPTION


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
        croak "Option '$unsupported' not supported\n"
          if exists $params->{$unsupported};
    }

    #
    # DEFAULTS, see Template::Manual::Config
    #
    my $defaults = {
        STRICT      => 1,
        ABSOLUTE    => 1,
        RELATIVE    => 1,
        CACHE_SIZE  => 0,
        INTERPLOATE => 0,
        EVAL_PERL   => 0,
        RAW_PERL    => 0,
        RECURSION   => 0,
    };

    # override defaults by params
    my $self = bless { params => { %$defaults, %$params } }, $class;

    return $self;
}

sub _build {
    my $self = shift;

    # our entry level is Template::Context, use Template method chain
    $self->{CONTEXT} = Template->new( $self->{params} )->service->context;

    return $self;
}

=head2 process

=cut

sub process {
    my ( $self, $template, $vars ) = @_;

    # create new Template ... objects for every process()
    $self->_build;

    my $ctx = $self->{CONTEXT};
    my $stash = $ctx->stash;

    #
    # processing template from Template::Document level and NOT
    # from Template::Service level to get the stash back
    #
    my ( $output, $error );
    try {
        my $compiled = $ctx->template($template);

        $stash->update( { template => $compiled } );
        $stash->update( $vars ) if defined $vars;

        $output = $compiled->process($ctx);
    }
    catch { $error = $_ };
    croak "$error" if $error;

    # remove initial stash keys like _STRICT, _DEBUG, inc, ...
    $self->_purge_stash;

    return wantarray ? ( $ctx->stash, $output ) : $ctx->stash;
}

sub _purge_stash {
    my $self = shift;

    my @purge_keys = qw(
      _PARENT
      _STRICT
      _DEBUG
      inc
      dec
    );

    my $stash      = $self->{CONTEXT}->stash;

    foreach my $key (@purge_keys) {

        next unless exists $stash->{$key};

        if ( $key eq '_STRICT' || $key eq '_DEBUG' || $key eq '_PARENT' ) {
            delete $stash->{$key};
            next;
        }

        # initial root VMethods inc, dec
        #
        if ( ref $stash->{$key} eq 'CODE' )
        {
            delete $stash->{$key};
            next;
        }
    }
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
