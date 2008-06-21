#!/usr/bin/perl -w

use strict;

use ExtUtils::MakeMaker;

WriteMakefile(
	NAME         => 'MooseX::Types::URI',
	VERSION_FROM => 'lib/MooseX/Types/URI.pm',
	INSTALLDIRS  => 'site',
	SIGN         => 1,
	PL_FILES     => { },
	PREREQ_PM    => {
		'Test::use::ok' => 0,
        'Moose' => '0.50',
        'MooseX::Types' => 0,
        'MooseX::Types::Path::Class' => 0,
        'URI' => 0,
        'URI::FromHash' => 0,
        'namespace::clean' => '0.08',
	},
);

