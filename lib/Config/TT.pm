package Config::TT;

use strict;
use warnings;

use Template::Config;
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

    # warn about unsupported Template::Service params
    my @unsupported = qw(PRE_PROCESS PROCESS POST_PROCESS AUTO_RESET ERROR);
    foreach my $unsupported (@unsupported) {
        carp "Option '$unsupported' not supported\n"
          if exists $params->{$unsupported};
    }

    # DEFAULTS
    my $defaults = {
        STRICT     => 1,    # croak on undefined vars
        CACHE_SIZE => 0,    # don't cache the config file
        ABSOLUTE   => 1,    # absolute filenames allowed
        RELATIVE   => 1,    # relative filenames allowed
    };

    # override defaults by params
    my $self = bless { params => { %$defaults, %$params } }, $class;

    $self->_init();
    return $self;
}

sub _init {
    my $self = shift;

    # CONTEXT from caller?
    if ( $self->{params}{CONTEXT} ) {
        $self->{CONTEXT} = $self->{params}{CONTEXT};
    }
    # CONTEXT via Template::Config factory
    else {
        $self->{CONTEXT} = Template::Config->context( $self->{params} );
    }

    return $self;
}

=head2 process

=cut

sub process {
    my ( $self, $template, $vars ) = @_;

    # reset CONTEXT
    $self->_init;

    my $ctx = $self->{CONTEXT};

    # HACK
    # delete PUBLIC global slot in context stash before processing
    delete $ctx->stash->{global};

    # update stash with given $vars
    $ctx->stash->update($vars) if $vars;

    # load Template::Document
    my $template_doc = $ctx->template($template);

    #  process it
    my $output = $template_doc->process($ctx);

    # prepare result stash ...
    my $result_stash = Template::Config->stash();

    # HACK
    # delete PUBLIC global slot in context stack before processing
    delete $result_stash->{global};

    $result_stash->update( $ctx->stash );

    # ... delete all private keys, coderefs and other internals
    foreach my $key ( keys %$result_stash ) {

	# delete private keys starting with '.' or '_'
        delete $result_stash->{$key} if $key =~ m/^[._]/;

	# delete VMethods like inc(), dec(), ... from config stash 
        delete $result_stash->{$key} if ref $result_stash->{$key} eq 'CODE';
    }

    return wantarray ? ( $result_stash, $output ) : $result_stash;
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
