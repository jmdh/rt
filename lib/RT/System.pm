# BEGIN BPS TAGGED BLOCK {{{
#
# COPYRIGHT:
#
# This software is Copyright (c) 1996-2013 Best Practical Solutions, LLC
#                                          <sales@bestpractical.com>
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
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.html.
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

=head1 NAME 

RT::System

=head1 DESCRIPTION

RT::System is a simple global object used as a focal point for things
that are system-wide.

It works sort of like an RT::Record, except it's really a single object that has
an id of "1" when instantiated.

This gets used by the ACL system so that you can have rights for the scope "RT::System"

In the future, there will probably be other API goodness encapsulated here.

=cut


package RT::System;

use strict;
use warnings;

use base qw/RT::Record/;

use Role::Basic 'with';
with "RT::Record::Role::Roles";

use RT::ACL;
use RT::ACE;

# System rights are rights granted to the whole system
# XXX TODO Can't localize these outside of having an object around.
our $RIGHTS = {
    SuperUser              => 'Do anything and everything',           # loc_pair
    AdminUsers     => 'Create, modify and delete users',              # loc_pair
    ModifySelf     => "Modify one's own RT account",                  # loc_pair
    ShowConfigTab => "Show Configuration tab",     # loc_pair
    ShowApprovalsTab => "Show Approvals tab",     # loc_pair
    ShowGlobalTemplates => "Show global templates",     # loc_pair
    LoadSavedSearch => "Allow loading of saved searches",     # loc_pair
    CreateSavedSearch => "Allow creation of saved searches",      # loc_pair
    ExecuteCode => "Allow writing Perl code in templates, scrips, etc", # loc_pair
};

our $RIGHT_CATEGORIES = {
    SuperUser              => 'Admin',
    AdminUsers             => 'Admin',
    ModifySelf             => 'Staff',
    ShowConfigTab          => 'Admin',
    ShowApprovalsTab       => 'Admin',
    ShowGlobalTemplates    => 'Staff',
    LoadSavedSearch        => 'General',
    CreateSavedSearch      => 'General',
    ExecuteCode            => 'Admin',
};

# Tell RT::ACE that this sort of object can get acls granted
$RT::ACE::OBJECT_TYPES{'RT::System'} = 1;

__PACKAGE__->AddRights(%$RIGHTS);
__PACKAGE__->AddRightCategories(%$RIGHT_CATEGORIES);

=head2 AvailableRights

Returns a hash of available rights for this object.
The keys are the right names and the values are a
description of what the rights do.

This method as well returns rights of other RT objects,
like L<RT::Queue> or L<RT::Group>. To allow users to apply
those rights globally.

If an L<RT::Principal> is passed as the first argument, the available rights
will be limited to ones which make sense for the principal.  Currently only
role groups are supported and rights announced by object types to which the
role group doesn't apply are not returned.

=cut

sub AvailableRights {
    my $self        = shift;
    my $principal   = shift;
    my @types       = keys %RT::ACE::OBJECT_TYPES;

    # Include global system rights by default
    my %rights = %{ $RIGHTS };

    # Only return rights on classes which support the role asked for
    if ($principal and $principal->IsRoleGroup) {
        my $role = $principal->Object->Type;
        @types   = grep { $_->DOES('RT::Record::Role::Roles') and $_->HasRole($role) } @types;
        %rights  = ();
    }

    # Build a merged list of system wide rights, queue rights, group rights, etc.
    %rights = (
        %rights,
        %{ $self->_ForACEObjectTypes(\@types => 'AvailableRights', @_) },
    );
    delete $rights{ExecuteCode} if RT->Config->Get('DisallowExecuteCode');

    return(\%rights);
}

sub _ForACEObjectTypes {
    my $self   = shift;
    my $types  = shift || [];
    my $method = shift;
    return {} unless @$types and $method;

    my %data;
    for my $class (sort @$types) {
        next unless $RT::ACE::OBJECT_TYPES{$class};

        # Skip ourselves otherwise we'd loop infinitely
        next if $class eq 'RT::System';

        my $object = $class->new(RT->SystemUser);

        unless ($object->can($method)) {
            RT->Logger->error("RT::ACE object type $class doesn't support the $method method! Skipping.");
            next;
        }

        # embrace and extend
        %data = (
            %data,
            %{ $object->$method(@_) || {} },
        );
    }

    return \%data;
}

=head2 RightCategories

Returns a hashref where the keys are rights for this type of object and the
values are the category (General, Staff, Admin) the right falls into.

=cut

sub RightCategories {
    my $self = shift;

    # Build a merged list of all right categories system wide, per-queue, per-group, etc.
    my %categories = (
        %{ $RIGHT_CATEGORIES },
        %{ $self->_ForACEObjectTypes([keys %RT::ACE::OBJECT_TYPES] => 'RightCategories') },
    );

    return \%categories;
}

=head2 AddRights C<RIGHT>, C<DESCRIPTION> [, ...]

Adds the given rights to the list of possible rights.  This method
should be called during server startup, not at runtime.

=cut

sub AddRights {
    my $self = shift if ref $_[0] or $_[0] eq __PACKAGE__;
    my %new = @_;
    $RIGHTS = { %$RIGHTS, %new };
    %RT::ACE::LOWERCASERIGHTNAMES = ( %RT::ACE::LOWERCASERIGHTNAMES,
                                      map { lc($_) => $_ } keys %new);
}

=head2 AddRightCategories C<RIGHT>, C<CATEGORY> [, ...]

Adds the given right and category pairs to the list of right categories.  This
method should be called during server startup, not at runtime.

=cut

sub AddRightCategories {
    my $self = shift if ref $_[0] or $_[0] eq __PACKAGE__;
    my %new = @_;
    $RIGHT_CATEGORIES = { %$RIGHT_CATEGORIES, %new };
}

sub _Init {
    my $self = shift;
    $self->SUPER::_Init (@_) if @_ && $_[0];
}

=head2 id

Returns RT::System's id. It's 1. 

=cut

*Id = \&id;
sub id { return 1 }

=head2 Load

Since this object is pretending to be an RT::Record, we need a load method.
It does nothing

=cut

sub Load    { return 1 }
sub Name    { return 'RT System' }
sub __Set   { return 0 }
sub __Value { return 0 }
sub Create  { return 0 }
sub Delete  { return 0 }

sub SubjectTag {
    my $self = shift;
    my $queue = shift;

    return $queue->SubjectTag if $queue;

    my $queues = RT::Queues->new( $self->CurrentUser );
    $queues->Limit( FIELD => 'SubjectTag', OPERATOR => 'IS NOT', VALUE => 'NULL' );
    return $queues->DistinctFieldValues('SubjectTag');
}

=head2 QueueCacheNeedsUpdate ( 1 )

Attribute to decide when SelectQueue needs to flush the list of queues
and retrieve new ones.  Set when queues are created, enabled/disabled
and on certain acl changes.  Should also better understand group management.

If passed a true value, will update the attribute to be the current time.

=cut

sub QueueCacheNeedsUpdate {
    my $self = shift;
    my $update = shift;

    if ($update) {
        return $self->SetAttribute(Name => 'QueueCacheNeedsUpdate', Content => time);
    } else {
        my $cache = $self->FirstAttribute('QueueCacheNeedsUpdate');
        return (defined $cache ? $cache->Content : 0 );
    }
}

=head2 AddUpgradeHistory package, data

Adds an entry to the upgrade history database. The package can be either C<RT>
for core RT upgrades, or the fully qualified name of a plugin. The data must be
a hash reference.

=cut

sub AddUpgradeHistory {
    my $self  = shift;
    my $package = shift;
    my $data  = shift;

    $data->{timestamp}  ||= time;
    $data->{rt_version} ||= $RT::VERSION;

    my $upgrade_history_attr = $self->FirstAttribute('UpgradeHistory');
    my $upgrade_history = $upgrade_history_attr ? $upgrade_history_attr->Content : {};

    push @{ $upgrade_history->{$package} }, $data;

    $self->SetAttribute(
        Name    => 'UpgradeHistory',
        Content => $upgrade_history,
    );
}

=head2 UpgradeHistory [package]

Returns the entries of RT's upgrade history. If a package is specified, the list
of upgrades for that package will be returned. Otherwise a hash reference of
C<< package => [upgrades] >> will be returned.

=cut

sub UpgradeHistory {
    my $self  = shift;
    my $package = shift;

    my $upgrade_history_attr = $self->FirstAttribute('UpgradeHistory');
    my $upgrade_history = $upgrade_history_attr ? $upgrade_history_attr->Content : {};

    if ($package) {
        return @{ $upgrade_history->{$package} || [] };
    }

    return $upgrade_history;
}

RT::Base->_ImportOverlays();

1;
