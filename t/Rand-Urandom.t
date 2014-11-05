use strict;
use warnings;

use Test::More tests => 11;
BEGIN { use_ok('Rand::Urandom', qw(perl_rand rand_bytes)) };

ok(\&CORE::GLOBAL::rand == \&Rand::Urandom::use_urandom, "rand() overloaded");

ok(rand() <= 1, '<= 1');
ok(rand(255) <= 255, '<= 255');

my $pid = open(my $fh, '-|');
die "failed to fork: $!" if(!defined $pid);
if ($pid) {
	my $got = <$fh>;
	close($fh);

	my $r = rand();
	ok(defined $got, "child returned");
	ok($got ne $r, "child/parent have different rand")
} else {
	print rand();
	exit 0;
}

ok(length(rand_bytes(8)) == 8, "rand_bytes");
ok(rand(2**64), "rand uint64");

# make sure original rand still works
SKIP: {
	skip "perl_rand() unsupported on perl < 5.16", 3 if($^V lt 'v5.16');

	# have to make a call first, to make sure srand() was called
	ok(defined perl_rand(), "perl_rand");

	$pid = open($fh, '-|');
	die "failed to fork: $!" if(!defined $pid);
	if ($pid) {
		my $got = <$fh>;
		close($fh);

		my $r = perl_rand();
		ok(defined $got, "child returned");
		ok($got eq $r, "orig rand still works $got $r");
	} else {
		print perl_rand();
		exit 0;
	}
};

