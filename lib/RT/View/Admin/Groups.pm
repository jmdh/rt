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
use warnings;
use strict;

package RT::View::Admin::Groups;
use Jifty::View::Declare -base;
use base 'RT::View::CRUD';

use constant object_type    => 'Group';
use constant tab_url        => '/Admin/Elements/GroupTabs';
use constant current_tab    => 'Admin/Groups/';

use constant display_columns => qw(id name description);

sub _current_collection {
    my $self = shift;
    my $c    = $self->SUPER::_current_collection();
    $c->limit_to_user_defined_groups();
    return $c;
}

=head2 view_field_name

Display each group's name as a hyperlink to the modify page

=cut

sub view_field_name {
    my $self = shift;
    my %args = @_;

    my $id = $args{action}->argument_value('id');

    my $field = $args{action}->form_field($args{field}, render_mode => 'read');

    # I don't see a clean way to do this :(
    $field->render_wrapper_start();
    $field->render_preamble();

    $field->render_label();

    # render the value with a hyperlink
    span {
        attr { class is "@{[ $field->classes ]} value" };
        hyperlink(
            label => "@{[$field->current_value]}",
            url   => "/Admin/Groups/Modify.html?id=$id",
        );
    };

    $field->render_wrapper_end();

    return;
}

1;

