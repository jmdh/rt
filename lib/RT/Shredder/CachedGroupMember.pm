# BEGIN BPS TAGGED BLOCK {{{
#
# COPYRIGHT:
#
# This software is Copyright (c) 1996-2007 Best Practical Solutions, LLC
#                                          <jesse@bestpractical.com>
#
# (Except where explicitly superseded by other copyright notices)
#
#
# LICENSE:
#
# This work is made available to you under the terms of Version 2 of
# the GNU General Public License. A copy of that license should have
# been provided with this software, but in any event can be snarfed
# from www.gnu.org.
#
# This work is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
# 02110-1301 or visit their web page on the internet at
# http://www.gnu.org/copyleft/gpl.html.
#
#
# CONTRIBUTION SUBMISSION POLICY:
#
# (The following paragraph is not intended to limit the rights granted
# to you to modify and distribute this software under the terms of
# the GNU General Public License and is only of importance to you if
# you choose to contribute your changes and enhancements to the
# community by submitting them to Best Practical Solutions, LLC.)
#
# By intentionally submitting any modifications, corrections or
# derivatives to this work, or any other work intended for use with
# Request Tracker, to Best Practical Solutions, LLC, you confirm that
# you are the copyright holder for those contributions and you grant
# Best Practical Solutions,  LLC a nonexclusive, worldwide, irrevocable,
# royalty-free, perpetual, license to use, copy, create derivative
# works based on those contributions, and sublicense and distribute
# those contributions and any derivatives thereof.
#
# END BPS TAGGED BLOCK }}}
use RT::Model::CachedGroupMember ();

package RT::Model::CachedGroupMember;

use strict;
use warnings;
use warnings FATAL => 'redefine';

use RT::Shredder::Constants;
use RT::Shredder::Exceptions;
use RT::Shredder::Dependency;

sub __depends_on {
    my $self = shift;
    my %args = (
        Shredder     => undef,
        Dependencies => undef,
        @_,
    );
    my $deps = $args{'Dependencies'};
    my $list = [];

    # deep memebership
    my $objs = RT::Model::CachedGroupMemberCollection->new;
    $objs->limit( column => 'Via', value => $self->id );
    $objs->limit( column => 'id', operator => '!=', value => $self->id );
    push( @$list, $objs );

# principal lost group membership and lost some rights which he could delegate to
# some body

 # XXX: Here is problem cause has_member_recursively would return true allways
 # cause we didn't delete anything yet. :(
 # if pricipal is not member anymore(could be via other groups) then proceed
    if ( $self->group_obj->object->has_member_recursively( $self->member_obj )
        )
    {
        my $acl = RT::Model::ACECollection->new;
        $acl->limit_to_principal( id => $self->group_id );

        # look into all rights that have group
        while ( my $ace = $acl->next ) {
            my $delegations = RT::Model::ACECollection->new;
            $delegations->delegated_from( id => $ace->id );
            $delegations->delegated_by( id => $self->member_id );
            push( @$list, $delegations );
        }
    }

    # XXX: Do we need to delete records if user lost right 'DelegateRights'?

    $deps->_push_dependencies(
        base_object   => $self,
        Flags         => DEPENDS_ON,
        target_objects => $list,
        Shredder      => $args{'Shredder'}
    );

    return $self->SUPER::__depends_on(%args);
}

#TODO: If we plan write export tool we also should fetch parent groups
# now we only wipeout things.

sub __Relates {
    my $self = shift;
    my %args = (
        Shredder     => undef,
        Dependencies => undef,
        @_,
    );
    my $deps = $args{'Dependencies'};
    my $list = [];

    my $obj = $self->member_obj;
    if ( $obj && $obj->id ) {
        push( @$list, $obj );
    } else {
        my $rec = $args{'Shredder'}->get_record( object => $self );
        $self = $rec->{'object'};
        $rec->{'State'} |= INVALID;
        $rec->{'description'}
            = "Have no related Principal #" . $self->member_id . " object.";
    }

    $obj = $self->group_obj;
    if ( $obj && $obj->id ) {
        push( @$list, $obj );
    } else {
        my $rec = $args{'Shredder'}->get_record( object => $self );
        $self = $rec->{'object'};
        $rec->{'State'} |= INVALID;
        $rec->{'description'}
            = "Have no related Principal #" . $self->group_id . " object.";
    }

    $deps->_push_dependencies(
        base_object   => $self,
        Flags         => RELATES,
        target_objects => $list,
        Shredder      => $args{'Shredder'}
    );
    return $self->SUPER::__Relates(%args);
}
1;
