package App::Kaizendo::Template::Plugin::AddID;
use Moose;
use MooseX::NonMoose;
use namespace::autoclean;

use HTML::Tree;
use Digest::SHA1 qw(sha1_hex);

use Template::Plugin::Filter;
extends qw( Moose::Object Template::Plugin::Filter );

sub BUILDARGS {
    my ( $class, $c, @args ) = @_;

    my $filter_args = { @args };
    $class->SUPER::BUILDARGS(@_);
	return { %$filter_args, context => $c, filter_args => $filter_args };
}

has context => (
	isa => "Object",
	is  => "ro",
);

has filter_obj => (
	isa => "Object",
	is  => "ro",
	lazy_build => 1,
);

has filter_args => (
	isa => "HashRef",
	is  => "ro",
	default => sub { {} },
);

sub _build_filter_obj {
	my $self = shift;

    my $tree = HTML::TreeBuilder->new();

    my $default_args = {
        implicit_tags => 0,
        implicit_body_p_tag => 0,
        ignore_unknown => 0,
        ignore_ignorable_whitespace => 1,
        no_space_compacting => 0,
        store_comments => 1,
    };

	my $args = $self->filter_args;

	for my $method (keys %$default_args, %$args) {
		if ( $tree->can($method) ) {
			$tree->$method( $args->{$method} );
		}
	}

	return $tree;
}

# sub BUILD {
	# my $self = shift;
    # $self->context->install_filter('add_ids');
# }


before init => sub { warn "\n\n###### init #####\n\n" };

after init => sub {
    my $self = shift;

    $self->{ _DYNAMIC } = 1;
    $self->context->install_filter('add_ids');

    return $self;
};

after new => sub {
    my $self = shift;
    $self->SUPER::new(@_);
};

sub filter {
    my ($self, $text) = @_;

    $text = $self->_add_ids($text);

    return $text;
}

sub _add_ids {
    my $self = shift;
    my $content = shift;
    my $content_sha1 = sha1_hex($content);

    # FIXME: Stupid hack to show that we have a specific content
    $content = qq(<div id="$content_sha1">$content</div>);

    my $tree = $self->filter_obj;

    $tree->parse($content);
    $tree->eof();
    my $guts = $tree->disembowel();

    my $id_counter = 0;
    _assign_id($guts, $id_counter);
    return $guts->as_HTML("", "  ", {});
}


sub _assign_id {
    my $x = $_[0];
    my $counter = $_[1];
    my $pos;
    $x->id('c_' . $counter++) unless defined $x->id;
    if( $x->content_list > 1) {
        foreach my $c ($x->content_list) {
            if (ref $c) {
                _assign_id($c, $counter);
            }
            else { 
                my $s = HTML::Element->new('span', id => 'c_' . $counter++);
                $s->push_content($c); # Wrap content with a span element
                $x->splice_content( $pos, 1, $s );
            }
            $pos++;
        }
    }
}


=head1 NAME

App::Kaizendo::Template::Plugin::AddID - TT Filter for adding ID attributes

=head1 DESCRIPTION

This module is a TT Filter for adding ID attributes to elements in a HTML
document.

=head1 SYNOPSIS

  [% USE AddID %]

  [% content | add_id %]


=head1 WHAT IT IS FOR

The algorithm used is based on COMT's discussion tool for text annotations,
described at L<http://www.co-ment.org/wiki/AnnotationInternals>.

The strategy is to traverse the content depth-first, adding unique IDs
as we go:

   - The content is wrapped with a <span> having the object
     UUID of the content as id
   - Elements that don't have an ID get one
   - Elements with an ID keep the one they have
   - Whitespace CDATA is stripped
   - Content CDATA get a <span> with an ID around it


=head1 SEE ALSO

L<App::Kaizendo::Web>, L<Template::Plugin::Filter>

=head1 AUTHORS, COPYRIGHT AND LICENSE

See L<App::Kaizendo> for Authors, Copyright and License information.

=cut

1;
