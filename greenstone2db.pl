#!/usr/bin/env perl

use strict;
use warnings;

use Mojo::DOM;
use Mojo::Util qw/slurp/;
use File::Find;

my $dir = shift || '.';
find(\&found, $dir);

my $db; #TODO connect to database here

sub found {
  return unless /\.xml$/;
  my $content = slurp $_;
  my $data = parse_content($content);
  load_data_into_db( $data, $db );
}

sub parse_content {
  my $content = shift;
}

sub load_data_into_db {
  my ($data, $db) = @_;
}

