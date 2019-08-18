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
    ...;
  }

  return 0;
}

sub tidy_file
{
  my($path) = @_;
  my @lines = do {
    my $fh = $path->openr;
    binmode $fh, ':utf8';
    <$fh>;
  };

  my $in_pod = 0;

  for my $line (0..$#lines)
  {
    if($lines[$line] =~ m/^=cut/)
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
    elsif($lines[$line] =~ m/^=/)
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

  $path->spew_utf8( @lines );
}

1;
