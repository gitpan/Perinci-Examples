
use strict;
use warnings;

use Module::Build 0.3601;


my %module_build_args = (
  "build_requires" => {
    "Module::Build" => "0.3601",
    "Test::More" => "0.96"
  },
  "configure_requires" => {
    "Module::Build" => "0.3601"
  },
  "dist_abstract" => "Example modules containing metadata and various example functions",
  "dist_author" => [
    "Steven Haryanto <stevenharyanto\@gmail.com>"
  ],
  "dist_name" => "Perinci-Examples",
  "dist_version" => "0.10",
  "license" => "perl",
  "module_name" => "Perinci::Examples",
  "recommends" => {},
  "recursive_test_files" => 1,
  "requires" => {
    "Log::Any" => 0,
    "Rinci" => "1.1.1",
    "perl" => "5.010000"
  },
  "script_files" => [
    "bin/peri-ex-test-completion"
  ]
);


my $build = Module::Build->new(%module_build_args);

$build->create_build_script;
