#!/usr/bin/env perl

use strict;
use warnings;

use Mojo::DOM;
use Mojo::Util qw/slurp/;
use File::Find;
use Text::CSV;
use Data::Printer output => 'stdout';
use DBI;

my $dir = shift || '.';
my @props = qw/
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
/;

my $dbh = DBI->connect("dbi:SQLite:database.db","","") or die "Could not connect";
# make sure table exists
get_insert_statement($dbh) || create_table($dbh);
my $sth = get_insert_statement($dbh);

find(\&found, $dir);

sub found {
  return unless $_ eq 'docmets.xml';
  my $content = slurp $_;
  my $data    = parse_content( $content );
  my $row     = data_to_row( $data );
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

  print "\nData:\n";
  p $data;

  return \%data;
}

sub data_to_row {
  my ($data, $db) = @_;
  my $csv = Text::CSV->new;
  my @row;
  for my $prop (@props) {
    my $values = $data->{$prop} || [];
    push @row, $csv->combine(@$values) ? $csv->string : '';
  }

  print "Row:\n";
  p $row;

  return \@row;
}

sub get_insert_statement {
  my $dbh = shift;
  my $statement = 
    'INSERT INTO dcrecords (' 
    . join( ', ', map { "'$_'" } @props )
    . ') VALUES ('
    . join( ', ', ('?') x @props )
    . ');';

  print "Insert Statement: $statement\n";

  return eval { $dbh->prepare($statement) };
}

sub create_table {
  my $dbh = shift;
  my $statement = 
    'CREATE TABLE dcrecords ('
    . join( ', ', map { "$_ VARCHAR" } @props )
    . ');';

  print "Creating Table: $statement\n";

  $dbh->do($statement);
}

