#!/usr/bin/perl
###########################################################################
# Copyright (C) 2001-2003 Peter J Jones (pjones@pmade.org)
# All Rights Reserved
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in
#    the documentation and/or other materials provided with the
#    distribution.
# 3. Neither the name of the Author nor the names of its contributors
#    may be used to endorse or promote products derived from this software
#    without specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS''
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
# TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
# PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR
# OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF
# USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED
# AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
# OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.
###########################################################################

use strict;
use lib qw(../harness);
use harness;

my $test = harness->new("xml::attributes");
runtests();

###########################################################################
sub runtests {
    my $actual_result;
    my $good_result;

    ###########################################################################
    foreach (qw(01a 01b 01c)) {
	$test->start("iteration ($_)");
	$actual_result = `./test_attr-01 data/$_.xml 2>&1`;

	if ($? != 0) {
	    $test->fail("test process returned $?");
	} else {
	    $good_result = $test->slurp_file("data/$_.out");

	    my $hash_a = make_hash($actual_result);
	    my $hash_b = make_hash($good_result);

	    if (not comp_hash($hash_a, $hash_b)) {
		$test->fail('output did not match expected value');
	    } else {
		$test->pass();
	    }
	}
    }
    ###########################################################################
    $test->regression("insert(name, value) (02)", "./test_attr-02 data/02.xml", "data/02.out");
    ###########################################################################
    foreach my $pair ((['one', 0], ['two', 0], ['three', 0], ['missing', 1], ['also_missing', 1])) {
	$test->run_test_exit_status("find(name) (03)", "./test_attr-03 data/03.xml $pair->[0]", $pair->[1]);
    }
    ###########################################################################
    foreach my $pair ((['a', 'attr_one'], ['b', 'attr_two'], ['c', 'attr_three'], ['d', 'attr_four'])) {
	$test->regression("remove(iterator) (04$pair->[0])", "./test_attr-04 data/04.xml $pair->[1]", "data/04$pair->[0].out");
    }
    ###########################################################################
    foreach my $pair ((['a', 'attr_one'], ['b', 'attr_two'], ['c', 'attr_three'], ['d', 'attr_four'])) {
	$test->regression("remove(const char*) (05$pair->[0])", "./test_attr-05 data/05.xml $pair->[1]", "data/05$pair->[0].out");
    }
    ###########################################################################
    foreach (qw(a b)) {
	$test->regression("empty (06$_)", "./test_attr-06 data/06$_.xml", "data/06$_.out");
    }
    ###########################################################################
    foreach (qw(a b c d)) {
	$test->regression("size (07$_)", "./test_attr-07 data/07$_.xml", "data/07$_.out");
    }
    ###########################################################################
    $test->start("copy constructor (08)");
    $actual_result = `./test_attr-08 data/08.xml 2>&1`;

    if ($? != 0) {
	$test->fail("test process returned $?");
    } else {
	$good_result = $test->slurp_file("data/08.out");

	my $hash_a = make_hash($actual_result);
	my $hash_b = make_hash($good_result);

	if (not comp_hash($hash_a, $hash_b)) {
	    $test->fail('output did not match expected value');
	} else {
	    $test->pass();
	}
    }
    ###########################################################################
    foreach ((['a', 'one'], ['b', 'two'], ['c', 'three'])) {
	$test->regression("dtd attr (09$_->[0])", "./test_attr-09 data/09.xml $_->[1]", "data/09$_->[0].out");
    }
    ###########################################################################
}
###########################################################################
sub make_hash {
    my $data = shift;
    my ($key, $value);
    my %hash;

    foreach my $line (split(/\n/, $data)) {
	my ($key, $value) = split(/=/, $line, 2);
	next if not defined $key or not defined $value;
	$hash{$key} = $value;
    }

    return \%hash;
}
###########################################################################
sub comp_hash {
    my $hash_a = shift;
    my $hash_b = shift;

    if (scalar keys %$hash_a != scalar keys %$hash_b) { return 0; }
    foreach my $key (keys %$hash_a) {
	if (not exists $hash_b->{$key}) { return 0; }
	if ($hash_a->{$key} ne $hash_b->{$key}) { return 0; }
    }

    return 1;
}
###########################################################################
