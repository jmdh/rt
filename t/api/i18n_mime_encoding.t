use warnings;
use strict;

use RT::Test nodata => 1, tests => 4;
use RT::I18N;
use Encode;

my @warnings;
local $SIG{__WARN__} = sub {
    push @warnings, "@_";
};

my $result = encode( 'iso-8859-1', decode_utf8('À??') );

diag "normal mime encoding conversion: utf8 => iso-8859-1"
  if $ENV{TEST_VERBOSE};
{
    my $mime = MIME::Entity->build(
        Type => 'text/plain; charset=utf-8',
        Data => ['À中文'],
    );

    RT::I18N::SetMIMEEntityToEncoding( $mime, 'iso-8859-1', );
    like(
        join( '', @warnings ),
        qr/does not map to iso-8859-1/,
        'get no-map warning'
    );
    is( $mime->stringify_body, $result,
        'invalid chars in mail are replaced by ?' );
    @warnings = ();
}

diag "force mime encoding conversion: utf8 => iso-8859-1"
  if $ENV{TEST_VERBOSE};
{
    my $mime     = MIME::Entity->build(
        Type => 'text/plain; charset=utf-8',
        Data => ['À中文'],
    );
    RT::I18N::SetMIMEEntityToEncoding( $mime, 'iso-8859-1', '', 1 );
    is( scalar @warnings, 0, 'no warnings with force' );
    is( $mime->stringify_body, $result,
        'invalid chars in mail are replaced by ?' );
}

