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

use subs 'debug';

GetOptions(
  'verbose'    => \my $verbose,
  'table=s'    => \(my $table    = 'dcrecords'  ),
  'database=s' => \(my $database = 'database.db'),
  'file=s'     => \(my $file     = 'docmets.xml'),
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

my $dbh = DBI->connect("dbi:SQLite:$database","","") or die "Could not connect";
check_table($dbh, $table, $props);
my $sth = get_insert_statement($dbh, $table, $props);

find(\&found, $dir);

sub found {
  return unless $_ eq $file;
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

  debug 'Data' => \%data;

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

  debug 'Row' => \@row;

  return \@row;
}

sub get_insert_statement {
  my ($dbh, $table, $props) = @_;
  my $statement = sprintf(
    'INSERT INTO %s ( %s ) VALUES ( %s );', 
    $table,
    join( ', ', @$props ), 
    join( ', ', ('?') x @$props )
  );

  debug 'Insert Statement' => $statement;

  return $dbh->prepare($statement);
}

sub check_table {
  my ($dbh, $table, $props) = @_;

  {
    # hide an expected warning
    local $SIG{__WARN__} = sub { warn @_ unless $_[0] =~ /no such table/ };
    return if eval { get_insert_statement($dbh, $props) };
  }

  warn "Creating table '$table'\n";

  my $statement = sprintf(
    'CREATE TABLE %s ( %s );',
    $table,
    join( ', ', map { "$_ VARCHAR" } @$props )
  );

  debug 'Create Statement' => $statement;

  $dbh->do($statement);
}

sub debug {
  return unless $verbose;
  my ($message, $data) = @_;
  print "\n$message:\n";
  p $data;
}

