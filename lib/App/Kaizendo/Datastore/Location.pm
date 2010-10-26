package App::Kaizendo::Datastore::Location;
use App::Kaizendo::Moose;  # Set up Moose environment


# use aliased 'App::Kaizendo::Datastore::Path';
use MooseX::Types::Moose qw/ Int Str ArrayRef /;

has start_path   => ( is => 'ro', required => 1, isa => Str );
has start_offset => ( is => 'ro', required => 1, isa => Int );
has end_path     => ( is => 'ro', required => 1, isa => Str ); 
has end_offset   => ( is => 'ro', required => 1, isa => Int );
has child_paths  => ( is => 'ro', isa => ArrayRef ); # FIXME: handle sub-tree context in a better way
has url          => ( is => 'ro', isa => Str ); # document level context


__PACKAGE__->meta->make_immutable;
1;

=head1 AUTHORS, COPYRIGHT AND LICENSE

See L<App::Kaizendo> for Authors, Copyright and License information.

=cut
