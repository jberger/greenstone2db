#!/usr/bin/env perl

use strict;
use warnings;

use Mojo::DOM;
use Mojo::Util qw/slurp/;
use File::Find;
use Text::CSV;
use Data::Printer output => 'stdout';
use DBI;
use Getopt::Long;

GetOptions(
  verbose => \my $verbose,
);

my $dir = shift || '.';
my $props = [ qw/
  Title
  Creator
  Subject
  Description
  Publisher
  Contributor
  Date
  Type
  Format
  Identifier
  Source
  Language
  Relation
  Coverage
  Rights 
/ ];

my $dbh = DBI->connect("dbi:SQLite:database.db","","") or die "Could not connect";
check_table($dbh, $props);
my $sth = get_insert_statement($dbh, $props);

find(\&found, $dir);

sub found {
  return unless $_ eq 'docmets.xml';
  my $content = slurp $_;
  my $data    = parse_content( $content );
  my $row     = data_to_row( $data, $props );
  $sth->execute(@$row);
}

sub parse_content {
  my $content = shift;
  my $dom = Mojo::DOM->new($content);
  my %data;
  for my $e ($dom->find('[name^=dc.]')->each) {
    my $key = $e->{name};
    $key =~ s/^dc\.//;
    push @{ $data{$key} }, $e->text;
  }

  if ($verbose) {
    print "\nData:\n";
    p %data;
  }

  return \%data;
}

sub data_to_row {
  my ($data, $props) = @_;
  my $csv = Text::CSV->new;
  my @row;
  for my $prop (@$props) {
    my $values = $data->{$prop} || [];
    push @row, $csv->combine(@$values) ? $csv->string : '';
  }

  if ($verbose) {
    print "Row:\n";
    p @row;
  }

  return \@row;
}

sub get_insert_statement {
  my ($dbh, $props) = @_;
  my $statement = 
    'INSERT INTO dcrecords (' 
    . join( ', ', @$props )
    . ') VALUES ('
    . join( ', ', ('?') x @$props )
    . ');';

  print "Insert Statement: $statement\n" if $verbose;

  return $dbh->prepare($statement);
}

sub check_table {
  my ($dbh, $props) = @_;

  {
    # hide an expected warning
    local $SIG{__WARN__} = sub { warn @_ unless $_[0] =~ /no such table/ };
    return if eval { get_insert_statement($dbh, $props) };
  }

  warn "Creating table 'dcrecords'\n";

  my $statement = 
    'CREATE TABLE dcrecords ('
    . join( ', ', map { "$_ VARCHAR" } @$props )
    . ');';

  print "Create Statement: $statement\n" if $verbose;

  $dbh->do($statement);
}

