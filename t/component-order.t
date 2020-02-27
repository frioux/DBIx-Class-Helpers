#!perl

use strict;
use warnings;

use Test::More;

{
    package MyBase1;
    use strict;
    use warnings;
    use parent 'DBIx::Class::Core';
    __PACKAGE__->load_components(
        'InflateColumn::DateTime',
        'Helper::Row::SelfResultSet',
    );
}

{
    package MyBase2;
    use strict;
    use warnings;
    use parent 'DBIx::Class::Core';
    __PACKAGE__->load_components(
        'Helper::Row::SelfResultSet',
        'InflateColumn::DateTime',
    );
}

BEGIN {
    $INC{'MyBase1.pm'} = __FILE__;
    $INC{'MyBase2.pm'} = __FILE__;
}

{
    package MyRow1;
    use strict;
    use warnings;
    use parent 'MyBase1';
}

{
    package MyRow2;
    use strict;
    use warnings;
    use parent 'MyBase2';
}

for my $class (qw(MyBase1 MyBase2 MyRow1 MyRow2)) {
    is(
        $class->can('register_column'),
        DBIx::Class::InflateColumn::DateTime->can('register_column'),
        "$class should register inflated columns",
    );
}

done_testing;
