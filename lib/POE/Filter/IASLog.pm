package POE::Filter::IASLog;

use strict;
use warnings;
use Parse::IASLog;
use base qw(POE::Filter);
use vars qw($VERSION);

$VERSION = '1.08';

sub new {
  my $class = shift;
  my %opts = @_;
  $opts{lc $_} = delete $opts{$_} for keys %opts;
  $opts{enumerate} = 1 unless defined $opts{enumerate} and !$opts{enumerate};
  $opts{BUFFER} = [];
  $opts{IAS} = Parse::IASLog->new( enumerate => $opts{enumerate} );
  return bless \%opts, $class;
}

sub get_one_start {
  my ($self, $raw) = @_;
  push @{ $self->{BUFFER} }, $_ for @$raw;
}

sub get_one {
  my $self = shift;
  my $events = [];

  my $event = shift @{ $self->{BUFFER} };
  if ( defined $event ) {
    my $record = $self->{IAS}->parse($event);
    push @$events, $record if $record;
  }
  return $events;
}

sub get_pending {
  my $self = shift;
  return $self->{BUFFER};
}

sub put {
  return;
}

sub clone {
  my $self = shift;
  my $nself = { };
  $nself->{$_} = $self->{$_} for keys %{ $self };
  $nself->{BUFFER} = [ ];
  return bless $nself, ref $self;
}

1;
__END__

=head1 NAME

POE::Filter::IASLog - A POE Filter for Microsoft IAS-formatted log entries.

=head1 SYNOPSIS

  my $filter = POE::Filter::IASLog->new();

  $arrayref_of_logical_chunks =
    $filter->get($arrayref_of_raw_chunks_from_driver);

=head1 DESCRIPTION

POE::Filter::IASLog is a L<POE::Filter> for parsing lines of text that are formatted in Microsoft
Internet Authentication Service (IAS) log format, where attributes are logged as attribute-value pairs.

It is intended to be used in a stackable filter, L<POE::Filter::Stackable>, with L<POE::Filter::Line>.

=head1 CONSTRUCTOR

=over

=item C<new>

Creates a new POE::Filter::IASLog object. Takes one optional parameter:

  'enumerate', set to a false value to disable the enumeration of known
	       attribute values, default is 1;

=back

=head1 METHODS

=over

=item C<get>

=item C<get_one_start>

=item C<get_one>

Takes an arrayref which is contains lines of IAS-formatted text, returns an arrayref of IAS hashref records,
see L<Parse::IASLog> for details of what a record will contain.

=item C<get_pending>

Returns the filter's partial input buffer.

=item C<put>

The put method is not implemented.

=item C<clone>

Makes a copy of the filter, and clears the copy's buffer.

=back

=head1 AUTHOR

Chris C<BinGOs> Williams <chris@bingosnet.co.uk>

=head1 LICENSE

Copyright E<copy> Chris Williams

This module may be used, modified, and distributed under the same terms as Perl itself. Please see the license that came with your Perl distribution for details.

=head1 SEE ALSO

L<Parse::IASLog>

L<POE::Filter::Stackable>

L<POE::Filter::Line>

=cut
