package App::spacetidy;

use strict;
use warnings;
use 5.008001;
use Path::Tiny qw( path );

# ABSTRACT: The wrong perl tidy
# VERSION

=head1 SYNOPSIS

 use App::spacetidy;
 ...

=head1 DESCRIPTION

Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad
minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit
in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui
officia deserunt mollit anim id est laborum.

 for(1..10)
 {
   say "hello world\n";
 }
 
 # some time later
 
 my $foo = Foo->new;

Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad
minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit
in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui
officia deserunt mollit anim id est laborum.

=cut

sub main
{
  my $class = shift;
  if(@_)
  {
    tidy_file(path($_)) for @_;
  }
  else
  {
    recurse(path('.'));
  }

  return 0;
}

sub recurse
{
  my($root) = @_;

  foreach my $path ($root->children)
  {
    next if $path->basename =~ /^\./;

    next if -l $path;

    if(-d $path)
    {
      next if $path->basename eq 'blib';
      recurse($path);
      next;
    }

    if($path->basename =~ /\.(pm|pl|t|PL|fbx)$/ || $path->basename =~ /^(alien|cpan)file$/)
    {
      print "$path\n";
      tidy_file($path);
    }
    elsif($path->basename =~ /\.(xs|c|cxx|cpp|h|rs|go)/
    ||    $path->basename eq 'dist.ini'
    ||    $path->basename eq 'perlcriticrc')
    {
      print "$path\n";
      tidy_file($path, 0);
    }
    else
    {
      my $fh = $path->openr;
      my $shebang = <$fh>;
      close $fh;

      next unless defined $shebang;

      if($shebang =~ m{^#!\S+/perl$})
      {
        print "$path\n";
        tidy_file($path);
      }
      elsif($shebang =~ m{^#!/usr/bin/env perl})
      {
        print "$path\n";
        tidy_file($path);
      }
    }
  }
}

sub tidy_file
{
  my($path, $is_perl) = @_;

  $is_perl = 1 unless defined $is_perl;

  my @lines = do {
    my $fh = $path->openr;
    binmode $fh, ':utf8';
    <$fh>;
  };

  my $in_pod = 0;

  for my $line (0..$#lines)
  {
    if($is_perl && $lines[$line] =~ m/^=cut/)
    {
      if($in_pod)
      {
        $in_pod = 0;
      }
      else
      {
        die "found =cut outside of POD: $path line $line";
      }
    }
    elsif($is_perl && $lines[$line] =~ m/^=/)
    {
      $in_pod = 1;
    }

    if($in_pod
    && $lines[$line] =~ m/^\s*$/
    && defined $lines[$line+1] && $lines[$line+1] =~ /^\s+\S/
    && defined $lines[$line-1] && $lines[$line-1] =~ /^\s+\S/)
    {
      $lines[$line] = " \n";
    }
    else
    {
      $lines[$line] =~ s/\s+$/\n/;
    }

    $line++;
  }

  my $mode = $path->stat->[2];
  $path->spew_utf8( @lines );
  $path->chmod($mode);
}

1;
