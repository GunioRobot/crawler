package Fetcher;

use strict;
use DB;
use MediaWords;
use LWP::UserAgent;

sub new
{
    my ( $class, $engine ) = @_;

    my $self = {};
    bless( $self, $class );

    $self->engine( $engine );

    return $self;
}

sub do_fetch
{
    my ( $download, $dbs ) = @_;

    $download->{ download_time } = 'now()';
    $download->{ state }         = 'fetching';

    $dbs->update_by_id( "downloads", $download->{ downloads_id }, $download );

    my $ua = LWP::UserAgent->new();

    $ua->from( 'mediawords@cyber.law.harvard.edu' );
    $ua->agent( 'crawler bot (http://cyber.law.harvard.edu)' );

    $ua->timeout( 20 );
    $ua->max_size( 1024 * 1024 );
    $ua->max_redirect( 15 );

    my $response = $ua->get( $download->{ url } );
    return $response;
}

sub fetch_download
{
    my ( $self, $download ) = @_;

    my $dbs = $self->engine->dbs;

    # FIXME - need to handle redirect manually, sticking them back into the queue as downloads
    # so that the host throttling works as it should
    
    #print "fetcher " . $self->engine->fetcher_number . " download: " . $download->{url} . "\n";

    return do_fetch( $download, $dbs );
}

# calling engine
sub engine
{
    if ( $_[ 1 ] )
    {
        $_[ 0 ]->{ engine } = $_[ 1 ];
    }

    return $_[ 0 ]->{ engine };
}

1;
