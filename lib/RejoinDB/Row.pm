package RejoinDB::Row;

use strict;
use warnings;

use base 'DBIx::Class::Core';

use overload
    '""'     => sub { shift->stringify },
    'bool'   => sub { 1 },
    fallback => 1;

__PACKAGE__->load_components('InflateColumn::DateTime');

1;

