package App::Kaizendo::Web::Controller::Root;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller::REST' }

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config(namespace => '');

=head1 NAME

Kaizendo::Controller::Root - Root Controller for Kaizendo

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=head2 index

The root page (/)

=cut

sub base : Chained('/') PathPart('') CaptureArgs(0) {}

sub index : Chained('base') PathPart('') Args(0) : ActionClass('REST') {
    my ( $self, $c ) = @_;
}

=head2 default

Standard 404 error page

=cut

sub default : Path : ActionClass('REST') {
    my ( $self, $c ) = @_;
    $c->response->body( 'Page not found' );
    $c->response->status(404);
}

=head1 AUTHOR

Salve J. Nilsen <sjn@kaizendo.org>

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the terms of the GNU Affero General Public License v3, AGPLv3.

See L<http://opensource.org/licenses/agpl-v3.html> for details.

=cut

__PACKAGE__->meta->make_immutable;

1;
