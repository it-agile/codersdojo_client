use strict;
use Test;

sub %kata_file% {
    return "fixme";
}

BEGIN { plan tests => 1, todo => [0] }

ok( %kata_file%(), "foo" );
