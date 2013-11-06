package Tuba::DB::Object::Reference;
# Tuba::DB::Mixin::Object::Reference;
use strict;
use Pg::hstore;
use Encode;

__PACKAGE__->meta->column('attrs')->add_trigger(
    inflate => sub {
        my ($o,$v) = @_;
        my $h = Pg::hstore::decode($v);
        do { $_ = decode('UTF8',$_) } for values %$h;
        return $h;
    });

__PACKAGE__->meta->column('attrs')->add_trigger(
    deflate => sub {
        my ($o,$v) = @_;
        do { $_ = encode('UTF8',$_) } for values %$v;
        return Pg::hstore::encode($v);
    });

sub as_tree {
    my $s = shift;
    return $s->SUPER::as_tree(@_, deflate => 0);
}

sub parent {
    return shift->publication_map->parent_publication->to_object;
}

sub child {
    return shift->publication_map->child_publication->to_object;
}

sub stringify {
    my $s = shift;
    my %args = @_;
    my $uuid = $s->identifier;
    if ($args{short}) {
        if ($uuid =~ /^(\w+)-(\w+)-(\w+)-(\w+)-(\w+)$/) {
            return $1;
        }
    }
    return $uuid;
}
1;

