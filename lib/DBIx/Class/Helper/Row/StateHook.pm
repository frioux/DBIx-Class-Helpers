package DBIx::Class::Helper::Row::StateHook;

use strict;
use warnings;

use parent 'DBIx::Class';

__PACKAGE__->load_components(
   'Helper::Row::StateHook::Insert',
   'Helper::Row::StateHook::Update',
);

1;

