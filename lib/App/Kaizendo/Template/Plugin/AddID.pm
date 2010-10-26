package App::Kaizendo::Template::Plugin::AddID;

use HTML::Tree;
use Digest::SHA1 qw(sha1_hex);

use Template::Plugin::Filter;
use base qw( Template::Plugin::Filter );

use warnings;
use strict;

use Carp qw(verbose);

sub init {
    my $self = shift;

    $self->{ _DYNAMIC } = 1;
    $self->install_filter('add_ids');

    return $self;
};

sub filter {
    my ($self, $text) = @_;

    return $self->_add_ids($text);
}

sub _add_ids {
    my $self = shift;
    my $content = shift;
    my $content_sha1 = sha1_hex($content);

    # FIXME: Stupid hack to show that we have a specific content
    $content = qq(<div id="$content_sha1">$content</div>);

    my $tree = HTML::TreeBuilder->new();

    $tree->implicit_tags(0);
    $tree->implicit_body_p_tag(0);
    $tree->ignore_unknown(0);
    $tree->ignore_ignorable_whitespace(1);
    $tree->no_space_compacting(0);
    $tree->store_comments(1);
    $tree->warn(1);
    $tree->store_pis(1);
    $tree->store_declarations(1);
    $tree->ignore_text(0);

    $tree->parse($content);
    $tree->eof();
    my $guts = $tree->disembowel();

    my $id_counter = 0;
    _assign_id($guts, $id_counter);

    return $guts->as_HTML(undef, "  ", {});

}


sub _assign_id {
    my $x = $_[0];
    my $counter = $_[1];
    my $pos = 0; my $id_added = 0;

    if (! defined $x->id) {
        $x->id('s_' . $_[1]++); # No ID? Add one.
        $id_added = 1;
    }
    
    if( $x->descendants > 0 ) {
        foreach my $c ($x->content_list) {
            if (ref $c) {
                _assign_id($c, $_[1]);
            }
            else {
                my $s = HTML::Element->new('span', id => 's_' . $_[1]++);
                $s->push_content($c); # Wrap content with a span element
                $x->splice_content( $pos, 1, $s ); # Then replace original
            }
            $pos++;
        }
    }
    elsif( $x->content_list and ! $id_added ) { # No descendants, but w/content
        my $s = HTML::Element->new('span', id => 's_' . $_[1]++);
        $s->push_content($x->content_list);
        $x->splice_content( 0, 1, $s );
    }
}


=head1 NAME

App::Kaizendo::Template::Plugin::AddID - TT Filter for adding ID attributes

=head1 DESCRIPTION

This module is a TT Filter for adding ID attributes to elements in a HTML
document.

=head1 SYNOPSIS

  [% USE AddID %]

  [% content | add_ids %]


=head1 WHAT IT IS FOR

The algorithm used is based on COMT's discussion tool for text annotations,
described at L<http://www.co-ment.org/wiki/AnnotationInternals>.

The strategy is to traverse the content depth-first, adding unique IDs
as we go:

   - The full content is wrapped with a <span> having an object
     UUID of the content as id (currently a SHA1 of the original content)
   - Elements that don't have an ID get one
   - Elements with an ID keep the one they have
   - Elements with an ID but only text content get that content wrapped
     in a <span> tag with an ID
   - Ignorable whitespace CDATA is stripped
   - Content CDATA get a <span> with an ID around it


=head1 SEE ALSO

L<App::Kaizendo::Web>, L<Template::Plugin::Filter>

=head1 AUTHORS, COPYRIGHT AND LICENSE

See L<App::Kaizendo> for Authors, Copyright and License information.

=cut

1;
