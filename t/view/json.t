use strict;
use warnings;
use lib 't/lib';
use Test::More;
use HTTP::Request::Common 'POST';
use MetaCPAN::Web::Test;
use JSON::MaybeXS;

sub post_json {
    POST(
        shift(),
        Content      => shift(),
        Content_type => 'application/json',
        @_
    );
}

my $cb;

sub echo_json_ok {
    my ( $json, $desc ) = @_;

    subtest $desc => sub {
        my $exp = decode_json($json);

        ok( my $res = $cb->( post_json '/test/json_echo', $json ),
            'http post' );
        is( $res->code, 200, '200 OK' );

        my $res_json = $res->content;
        ok( my $obj = eval { decode_json($res_json); }, 'decode json' );

        note "received: $res_json";

        is_deeply $obj, { echo => $exp }, "json passed through unchanged";
    };
}

test_psgi app, sub {
    $cb = shift;    # global
};

{

    echo_json_ok( q!{"test": 1}!, 'minimal json' );

    echo_json_ok( q!{"test": [1, 2, {"hash": {}}] }!, 'arrays and hashes' );

    local $TODO = 'errors encoding boolean objects';
    echo_json_ok( q!{"test": true}!, 'booleans' );
}

done_testing;
