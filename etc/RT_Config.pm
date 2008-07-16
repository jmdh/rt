
package RT;

=head1 NAME

RT::Config

=for testing

use RT::Config;

=cut

=head1 WARNING

NEVER EDIT RT_Config.pm.

Instead, copy any sections you want to change to F<RT_SiteConfig.pm> and edit them there.

=cut

=head1 Base Configuration

=over 4

=item C<$rtname>

C<$rtname> is the string that RT will look for in mail messages to
figure out what ticket a new piece of mail belongs to.

Your domain name is recommended, so as not to pollute the namespace.
once you start using a given tag, you should probably never change it.
(otherwise, mail for existing tickets won't get put in the right place)

=cut

Set($rtname , "example.com");


=item C<$EmailSubjectTagRegex>

This regexp controls what subject tags RT recognizes as its own.
If you're not dealing with historical C<$rtname> values, you'll likely
never have to enable this feature.

Be VERY CAREFUL with it. Note that it overrides C<$rtname> for subject
token matching and that you should use only "non-capturing" parenthesis
grouping. For example:

C<Set($EmailSubjectTagRegex, qr/(?:example.com|example.org)/i );>

and NOT

C<Set($EmailSubjectTagRegex, qr/(example.com|example.org)/i );>

This setting would make RT behave exactly as it does without the 
setting enabled.

=cut

#Set($EmailSubjectTagRegex, qr/\Q$rtname\E/i );



=item C<$Organization>

You should set this to your organization's DNS domain. For example,
I<fsck.com> or I<asylum.arkham.ma.us>. It's used by the linking interface to
guarantee that ticket URIs are unique and easy to construct.

=cut

Set($Organization , "example.com");

=item C<$MinimumPasswordLength>

C<$MinimumPasswordLength> defines the minimum length for user
passwords. Setting it to 0 disables this check.

=cut

Set($MinimumPasswordLength , "5");

=item C<$Timezone>

C<$Timezone> is used to convert times entered by users into GMT and back again
It should be set to a timezone recognized by your local unix box.

=cut

Set($Timezone , 'US/Eastern');

=back

=head1 Database Configuration

=over 4

=item C<$DatabaseType>

Database driver being used; case matters.

Valid types are "mysql", "Oracle" and "Pg"

=cut

Set($DatabaseType , 'SQLite');

=item C<$DatabaseHost>, C<$DatabaseRTHost>

The domain name of your database server.

If you're running mysql and it's on localhost,
leave it blank for enhanced performance

=cut

Set($DatabaseHost   , 'localhost');
Set($DatabaseRTHost , 'localhost');

=item C<$DatabasePort>

The port that your database server is running on.  Ignored unless it's
a positive integer. It's usually safe to leave this blank

=cut

Set($DatabasePort , '');

=item C<$DatabaseUser>

The name of the database user (inside the database)

=cut

Set($DatabaseUser , 'rt_user');

=item C<$DatabasePassword>

Password the C<$DatabaseUser> should use to access the database

=cut

Set($DatabasePassword , 'rt_pass');

=item C<$DatabaseName>

The name of the RT's database on your database server

=cut

Set($DatabaseName , 'rt3');

=item C<$DatabaseRequireSSL>

If you're using Postgres and have compiled in SSL support,
set C<$DatabaseRequireSSL> to 1 to turn on SSL communication

=cut

Set($DatabaseRequireSSL , undef);

=back

=head1 Incoming Mail Gateway Configuration

=over 4

=item C<$OwnerEmail>

C<$OwnerEmail> is the address of a human who manages RT. RT will send
errors generated by the mail gateway to this address.  This address
should _not_ be an address that's managed by your RT instance.

=cut

Set($OwnerEmail , 'root');

=item C<$LoopsToRTOwner>

If C<$LoopsToRTOwner> is defined, RT will send mail that it believes
might be a loop to C<$OwnerEmail>

=cut

Set($LoopsToRTOwner , 1);

=item C<$StoreLoops>

If C<$StoreLoops> is defined, RT will record messages that it believes
to be part of mail loops.

As it does this, it will try to be careful not to send mail to the
sender of these messages

=cut

Set($StoreLoops , undef);

=item C<$MaxAttachmentSize>

C<$MaxAttachmentSize> sets the maximum size (in bytes) of attachments stored
in the database.

For mysql and oracle, we set this size at 10 megabytes.
If you're running a postgres version earlier than 7.1, you will need
to drop this to 8192. (8k)

=cut


Set($MaxAttachmentSize , 10000000);

=item C<$TruncateLongAttachments>

C<$TruncateLongAttachments>: if this is set to a non-undef value,
RT will truncate attachments longer than C<$MaxAttachmentSize>.

=cut

Set($TruncateLongAttachments , undef);

=item C<$DropLongAttachments>

C<$DropLongAttachments>: if this is set to a non-undef value,
RT will silently drop attachments longer than C<MaxAttachmentSize>.

=cut

Set($DropLongAttachments , undef);

=item C<$ParsenewMessageForTicketCcs>

If C<$ParseNewMessageForTicketCcs> is true, RT will attempt to divine
Ticket 'Cc' watchers from the To and Cc lines of incoming messages
Be forewarned that if you have _any_ addresses which forward mail to
RT automatically and you enable this option without modifying
C<$RTAddressRegexp> below, you will get yourself into a heap of trouble.

=cut

Set($ParseNewMessageForTicketCcs , undef);

=item C<$RTAddressRegexp> 

C<$RTAddressRegexp> is used to make sure RT doesn't add itself as a ticket CC if
the setting above is enabled.

=cut

Set($RTAddressRegexp , '^rt\@example.com$');

=item C<$CanonicalizeEmailAddressMatch>, C<$CanonicalizeEmailAddressReplace>

RT provides functionality which allows the system to rewrite
incoming email addresses.  In its simplest form,
you can substitute the value in $<CanonicalizeEmailAddressReplace>
for the value in $<CanonicalizeEmailAddressMatch>
(These values are passed to the $<CanonicalizeEmailAddress> subroutine in
 F<RT/User.pm>)

By default, that routine performs a C<s/$Match/$Replace/gi> on any address
passed to it.

=cut

#Set($CanonicalizeEmailAddressMatch , '@subdomain\.example\.com$');
#Set($CanonicalizeEmailAddressReplace , '@example.com');

=item C<$CanonicalizeEmailAddressMatch>

Set this to true and the create new user page will use the values that you
enter in the form but use the function CanonicalizeUserInfo in
F<RT/User_Local.pm>

=cut

Set($CanonicalizeOnCreate, 0);

=item C<$SenderMustExistInExternalDatabase>

If C<$SenderMustExistInExternalDatabase> is true, RT will refuse to
create non-privileged accounts for unknown users if you are using
the C<$LookupSenderInExternalDatabase> option.
Instead, an error message will be mailed and RT will forward the
message to C<$RTOwner>.

If you are not using C<$LookupSenderInExternalDatabase>, this option
has no effect.

If you define an AutoRejectRequest template, RT will use this
template for the rejection message.

=cut

Set($SenderMustExistInExternalDatabase , undef);

=item C<@MailPlugins>

C<@MailPlugins> is a list of auth plugins for L<RT::Interface::Email>
to use; see L<rt-mailgate>

=cut

=item C<$UnsafeEmailCommands>

C<$UnsafeEmailCommands>, if set to true, enables 'take' and 'resolve'
as possible actions via the mail gateway.  As its name implies, this
is very unsafe, as it allows email with a forged sender to possibly
resolve arbitrary tickets!

=cut

=item C<$ExtractSubjectTagMatch>, C<$ExtractSubjectTagNoMatch>

The default "extract remote tracking tags" scrip settings; these
detect when your RT is talking to another RT, and adjusts the
subject accordingly.

=cut

Set($ExtractSubjectTagMatch, qr/\[.+? #\d+\]/);
Set($ExtractSubjectTagNoMatch, ( ${RT::EmailSubjectTagRegex}
       ? qr/\[(?:${RT::EmailSubjectTagRegex}) #\d+\]/
       : qr/\[\Q$RT::rtname\E #\d+\]/));

=back

=head1 Outgoing Mail Configuration

=over 4

=item C<$MailCommand>

C<$MailCommand> defines which method RT will use to try to send mail.
We know that 'sendmailpipe' works fairly well.  If 'sendmailpipe'
doesn't work well for you, try 'sendmail'.  Other options are 'smtp'
or 'qmail'.

Note that you should remove the '-t' from C<$SendmailArguments>
if you use 'sendmail' rather than 'sendmailpipe'

=cut

Set($MailCommand , 'sendmailpipe');

=back

=head1 Sendmail Configuration

These options only take effect if C<$MailCommand> is 'sendmail' or
'sendmailpipe'

=over 4

=item C<$SendmailArguments> 

C<$SendmailArguments> defines what flags to pass to C<$SendmailPath>
If you picked 'sendmailpipe', you MUST add a -t flag to C<$SendmailArguments>
These options are good for most sendmail wrappers and workalikes

These arguments are good for sendmail brand sendmail 8 and newer
C<Set($SendmailArguments,"-oi -t -ODeliveryMode=b -OErrorMode=m");>

=cut

Set($SendmailArguments , "-oi -t");


=item C<$SendmailBounceArguments>

C<$SendmailBounceArguments> defines what flags to pass to C<$Sendmail>
assuming RT needs to send an error (ie. bounce).

=cut

Set($SendmailBounceArguments , '-f "<>"');

=item C<$SendmailPath>

If you selected 'sendmailpipe' above, you MUST specify the path to
your sendmail binary in C<$SendmailPath>.

=cut

Set($SendmailPath , "/usr/sbin/sendmail");


=back

=head1 SMTP Configuration

These options only take effect if C<$MailCommand> is 'smtp'

=over 4

=item C<$SMTPServer>

C<$SMTPServer> should be set to the hostname of the SMTP server to use

=cut

Set($SMTPServer, undef);

=item C<$SMTPFrom>

C<$SMTPFrom> should be set to the 'From' address to use, if not the
email's 'From'

=cut

Set($SMTPFrom, undef);

=item C<$SMTPDebug> 

C<$SMTPDebug> should be set to true to debug SMTP mail sending

=cut

Set($SMTPDebug, 0);

=back

=head1 Other Mailer Configuration

=over 4

=item C<@MailParams>

C<@MailParams> defines a list of options passed to $MailCommand if it
is not 'sendmailpipe', 'sendmail', or 'smtp'

=cut

Set(@MailParams, ());

=item C<$CorrespondAddress>, C<$CommentAddress>

RT is designed such that any mail which already has a ticket-id associated
with it will get to the right place automatically.

C<$CorrespondAddress> and C<$CommentAddress> are the default addresses
that will be listed in From: and Reply-To: headers of correspondence
and comment mail tracked by RT, unless overridden by a queue-specific
address.

=cut

Set($CorrespondAddress , '');

Set($CommentAddress , '');

=item C<UseFriendlyFromLine>

By default, RT sets the outgoing mail's "From:" header to
"SenderName via RT".  Setting C<$UseFriendlyFromLine> to 0 disables it.

=cut

Set($UseFriendlyFromLine, 1);

=item C<$FriendlyFromLineFormat>

C<sprintf()> format of the friendly 'From:' header; its arguments
are SenderName and SenderEmailAddress.

=cut

Set($FriendlyFromLineFormat, "\"%s via RT\" <%s>");

=item C<$UseFriendlyToLine>

RT can optionally set a "Friendly" 'To:' header when sending messages to
Ccs or AdminCcs (rather than having a blank 'To:' header.

This feature DOES NOT WORK WITH SENDMAIL[tm] BRAND SENDMAIL
If you are using sendmail, rather than postfix, qmail, exim or some other MTA,
you _must_ disable this option.

=cut

Set($UseFriendlyToLine, 0);

=item C<$FriendlyToLineFormat>

C<sprintf()> format of the friendly 'From:' header; its arguments
are WatcherType and TicketId.

=cut

Set($FriendlyToLineFormat, "\"%s of ". RT->Config->Get('rtname') ." Ticket #%s\":;");

=item C<$NotifyActor>

By default, RT doesn't notify the person who performs an update, as they
already know what they've done. If you'd like to change this behaviour,
Set C<$NotifyActor> to 1

=cut

Set($NotifyActor, 0);

=item C<$RecordOutgoingEmail>

By default, RT records each message it sends out to its own internal database.
To change this behavior, set C<$RecordOutgoingEmail> to 0 

=cut

Set($RecordOutgoingEmail, 1);

=item C<$VERPPrefix>, C<$VERPPrefix>

VERP support (http://cr.yp.to/proto/verp.txt)

uncomment the following two directives to generate envelope senders
of the form C<${VERPPrefix}${originaladdress}@${VERPDomain}>
(i.e. rt-jesse=fsck.com@rt.example.com ).

This currently only works with sendmail and sendmailppie.

=cut

# Set($VERPPrefix, 'rt-');
# Set($VERPDomain, $RT::Organization);


=item C<$ForwardFromUser>

By default, RT forwards a message using queue's address and adds RT's tag into
subject of the outgoing message, so recipients' replies go into RT as correspondents.

To change this behavior, set C<$ForwardFromUser> to true value and RT will use
address of the current user and leave subject without RT's tag.

=cut

Set($ForwardFromUser, 0);

=item C<$ShowBccHeader>

By default RT hides from the web UI information about blind copies user sent on
reply or comment.

To change this set the following option to true value.

=cut

Set($ShowBccHeader, 0);

=back

=head1 GnuPG Configuration

A full description of the (somewhat extensive) GnuPG integration can be found 
by running the command `perldoc L<RT::Crypt::GnuPG>`  (or `perldoc
        lib/RT/Crypt/GnuPG.pm` from your RT install directory).

=over 4

=item C<%GnuPG>

Set C<OutgoingMessagesFormat> to 'inline' to use inline encryption and
signatures instead of 'RFC' (GPG/MIME: RFC3156 and RFC1847) format.

If you want to allow people to encrypt attachments inside the DB then
set C<AllowEncryptDataInDB> to true

=cut

Set( %GnuPG,
    Enable => 1,
    OutgoingMessagesFormat => 'RFC', # Inline
    AllowEncryptDataInDB   => 0,
);

=item C<%GnuPGOptions>

Options of GnuPG program.

If you override this in your RT_SiteConfig, you should be sure
to include a homedir setting.

NOTE that options with '-' character MUST be quoted.

=cut

Set(%GnuPGOptions,
    homedir => '/home/jesse/svk/3.999-DANGEROUS/var/data/gpg',

# URL of a keyserver
#    keyserver => 'hkp://subkeys.pgp.net',

# enables the automatic retrieving of keys when encrypting
#    'auto-key-locate' => 'keyserver',

# enables the automatic retrieving of keys when verifying signatures
#    'auto-key-retrieve' => undef,
);


=back

=head1 Logging Configuration

The default is to log anything except debugging
information to syslog.  Check the L<Log::Dispatch> POD for
information about how to get things by syslog, mail or anything
else, get debugging info in the log, etc.

It might generally make sense to send error and higher by email to
some administrator.  If you do this, be careful that this email
isn't sent to this RT instance.  Mail loops will generate a critical
log message.

=over 4

=item C<$LogToSyslog>, C<$LogToScreen>

The minimum level error that will be logged to the specific device.
From lowest to highest priority, the levels are:
 debug info notice warning error critical alert emergency

=cut

Set($LogToSyslog    , 'debug');
Set($LogToScreen    , 'info');

=item C<$LogToFile>, C<$LogDir>, C<$LogToFileNamed>

Logging to a standalone file is also possible, but note that the
file should needs to both exist and be writable by all direct users
of the RT API.  This generally include the web server, whoever
rt-crontool runs as.  Note that as rt-mailgate and the RT CLI go
through the webserver, so their users do not need to have write
permissions to this file. If you expect to have multiple users of
the direct API, Best Practical recommends using syslog instead of
direct file logging.

=cut

Set($LogToFile      , undef);
Set($LogDir, '/home/jesse/svk/3.999-DANGEROUS/var/log');
Set($LogToFileNamed , "rt.log");    #log to rt.log

=item C<$LogStackTraces>

If set to a log level then logging will include stack
traces for messages with level equal to or greater than
specified.

=cut

Set($LogStackTraces, '');

=item C<@LogToSyslogConf>

On Solaris or UnixWare, set to ( socket => 'inet' ).  Options here
override any other options RT passes to L<Log::Dispatch::Syslog>.
Other interesting flags include facility and logopt.  (See the
L<Log::Dispatch::Syslog> documentation for more information.)  (Maybe
ident too, if you have multiple RT installations.)

=cut

Set(@LogToSyslogConf, ());

=item C<$StatementLog>,

RT has rudimentary SQL statement logging support if you have
DBIx-SearchBuilder 1.31_1 or higher; simply set C<$StatementLog> to be
the level that you wish SQL statements to be logged at.

=cut

Set($StatementLog, undef);

=back

=head1 Web Interface Configuration

=over 4

=item C<$WebDefaultStylesheet>

This determines the default stylesheet the RT web interface will use.
RT ships with two valid values by default:

  3.5-default     The totally new, default layout for RT 3.5
  3.4-compat      A 3.4 compatibility stylesheet to make RT 3.5 look
                  (mostly) like 3.4

This value actually specifies a directory in F<share/html/NoAuth/css/>
from which RT will try to load the file main.css (which should
@import any other files the stylesheet needs).  This allows you to
easily and cleanly create your own stylesheets to apply to RT.  This
option can be overridden by users in their preferences.

=cut

Set($WebDefaultStylesheet, 'web2');

=item C<$UsernameFormat>

This determines how user info is displayed. Concise will show one of 
either NickName, RealName, Name or EmailAddress, depending on what exists 
and whether the user is privileged or not. Verbose will show RealName and
EmailAddress.

=cut

  Set($UsernameFormat, 'concise');


=item C<$WebPath>

If you're putting the web ui somewhere other than at the root of
your server, you should set C<$WebPath> to the path you'll be 
serving RT at.

C<$WebPath> requires a leading / but no trailing /.

In most cases, you should leave C<$WebPath> set to '' (an empty value).

=cut

Set($WebPath, "");

=item C<$WebPort>

If we're running as a superuser, run on port 80
Otherwise, pick a high port for this user.

=cut

Set($WebPort, 80);# + ($< * 7274) % 32766 + ($< && 1024));

=item C<$WebDomain>

you know what domain name is, right? ;)

=cut

Set( $WebDomain, 'localhost' );

=item C<$WebBaseURL>, C<$WebURL>

This is the Scheme, server and port for constructing urls to webrt
C<$WebBaseURL> doesn't need a trailing /

=cut

Set($WebBaseURL, 'http://' . RT->Config->Get('WebDomain') . ':' . RT->Config->Get('WebPort'));

Set($WebURL, RT->Config->Get('WebBaseURL') . RT->Config->Get('WebPath') . "/");

=item C<$WebImagesURL>

C<$WebImagesURL> points to the base URL where RT can find its images.
Define the directory name to be used for images in rt web
documents.

=cut

Set($WebImagesURL, RT->Config->Get('WebPath') . "/NoAuth/images/");

=item C<$LogoURL>

C<$LogoURL> points to the URL of the RT logo displayed in the web UI

=cut

Set($LogoURL, $Config->Get('WebImagesURL') . "bplogo.gif");

=item C<$WebNoAuthRegex>

What portion of RT's URLspace should not require authentication.

=cut

Set($WebNoAuthRegex, qr{^ (?:/+NoAuth/ | /+REST/\d+\.\d+/NoAuth/) }x );

=item C<$MessageBoxWidth>, C<$MessageBoxHeight>

For message boxes, set the entry box width, height and what type of
wrapping to use.  These options can be overridden by users in their
preferences.

Default width: 72, height: 15

=cut

Set($MessageBoxWidth, 72);
Set($MessageBoxHeight, 15);

=item C<$MessageBoxWrap>

Default wrapping: "HARD"  (choices "SOFT", "HARD")

=cut

Set($MessageBoxWrap, "HARD");

=item C<$MessageBoxRichText>

Should "rich text" editing be enabled? This option lets your users send html email messages from the web interface.

=cut

Set($MessageBoxRichText, 1);

=item C<$WikiImplicitLinks>

Support implicit links in WikiText custom fields?  A true value
causes InterCapped or ALLCAPS words in WikiText fields to
automatically become links to searches for those words.  If used on
RTFM articles, it links to the RTFM article with that name.

=cut

Set($WikiImplicitLinks, 0);

=item C<$TrustHTMLAttachments>

if C<TrustHTMLAttachments> is not defined, we will display them
as text. This prevents malicious HTML and javascript from being
sent in a request (although there is probably more to it than that)

=cut

Set($TrustHTMLAttachments, undef);

=item C<$RedistributeAutoGeneratedMessages>

Should RT redistribute correspondence that it identifies as
machine generated? A true value will do so; setting this to '0'
will cause no such messages to be redistributed.
You can also use 'privileged' (the default), which will redistribute
only to privileged users. This helps to protect against malformed
bounces and loops caused by autocreated requestors with bogus addresses.

=cut

Set($RedistributeAutoGeneratedMessages, 'privileged');

=item C<$PreferRichText>

If C<$PreferRichText> is set to a true value, RT will show HTML/Rich text
messages in preference to their plaintext alternatives. RT "scrubs" the 
html to show only a minimal subset of HTML to avoid possible contamination
by cross-site-scripting attacks.

=cut

Set($PreferRichText, undef);

=item C<$WebExternalAuth>

If C<$WebExternalAuth> is defined, RT will defer to the environment's
REMOTE_USER variable.

=cut

Set($WebExternalAuth, undef);

=item C<$WebFallbackToInternalAuth>

If C<$WebFallbackToInternalAuth> is undefined, the user is allowed a chance
of fallback to the login screen, even if REMOTE_USER failed.

=cut

Set($WebFallbackToInternalAuth , undef);

=item C<$WebExternalGecos>

C<$WebExternalGecos> means to match 'gecos' field as the user identity);
useful with mod_auth_pwcheck and IIS Integrated Windows logon.

=cut

Set($WebExternalGecos , undef);

=item C<$WebExternalAuto>

C<$WebExternalAuto> will create users under the same name as REMOTE_USER
upon login, if it's missing in the Users table.

=cut

Set($WebExternalAuto , undef);

=item C<$AutoCreate>

If C<$WebExternalAuto> is true, C<$AutoCreate> will be passed to User's
Create method.  Use it to set defaults, such as creating 
Unprivileged users with C<{ Privileged => 0 }>
( Must be a hashref of arguments )

=cut

Set($AutoCreate, undef);

=item C<$WebSessionClass>

C<$WebSessionClass> is the class you wish to use for managing Sessions.
It defaults to use your SQL database, but if you are using MySQL 3.x and
plans to use non-ascii Queue names, uncomment and add this line to
F<RT_SiteConfig.pm> will prevent session corruption.

=cut

# Set($WebSessionClass , 'Apache::Session::File');

=item C<$AutoLogoff>

By default, RT's user sessions persist until a user closes his or her 
browser. With the C<$AutoLogoff> option you can setup session lifetime in 
minutes. A user will be logged out if he or she doesn't send any requests 
to RT for the defined time.

=cut

Set($AutoLogoff, 0);

=item C<$WebSecureCookies>

By default, RT's session cookie isn't marked as "secure" Some web browsers 
will treat secure cookies more carefully than non-secure ones, being careful
not to write them to disk, only send them over an SSL secured connection 
and so on. To enable this behaviour, set C<$WebSecureCookies> to a true value. 
NOTE: You probably don't want to turn this on _unless_ users are only connecting
via SSL encrypted HTTP connections.

=cut

Set($WebSecureCookies, 0);

=item C<$WebFlushDbCacheEveryRequest>

By default, RT clears its database cache after every page view.
This ensures that you've always got the most current information 
when working in a multi-process (mod_perl or FastCGI) Environment
Setting C<$WebFlushDbCacheEveryRequest> to '0' will turn this off,
which will speed RT up a bit, at the expense of a tiny bit of data 
accuracy.

=cut

Set($WebFlushDbCacheEveryRequest, '1');


=item C<$MaxInlineBody>

C<$MaxInlineBody> is the maximum attachment size that we want to see
inline when viewing a transaction.  RT will inline any text if value
is undefined or 0.  This option can be overridden by users in their
preferences.

=cut

Set($MaxInlineBody, 12000);

=item C<$DefaultSummaryRows>

C<$DefaultSummaryRows> is default number of rows displayed in for search
results on the frontpage.

=cut

Set($DefaultSummaryRows, 10);

=item C<$OldestTransactionsFirst>

By default, RT shows newest transactions at the bottom of the ticket
history page, if you want see them at the top set this to '0'.  This
option can be overridden by users in their preferences.

=cut

Set($OldestTransactionsFirst, '1');

=item C<$ShowTransactionImages>

By default, RT shows images attached to incoming (and outgoing) ticket updates
inline. Set this variable to 0 if you'd like to disable that behaviour

=cut

Set($ShowTransactionImages, 1);


=item C<$ShowUnreadMessageNotifications>

By default, RT will prompt users when there are new, unread messages on
tickets they are viewing.

Set C<$ShowUnreadMessageNotifications> to a false value to disable this feature.

=cut

Set($ShowUnreadMessageNotifications, 1);


=item C<$HomepageComponents>

C<$HomepageComponents> is an arrayref of allowed components on a user's
customized homepage ("RT at a glance").

=cut

Set($HomepageComponents, [qw(QuickCreate Quicksearch MyAdminQueues MySupportQueues MyReminders RefreshHomepage)]);

=item C<@MasonParameters>

C<@MasonParameters> is the list of parameters for the constructor of
HTML::Mason's Apache or CGI Handler.  This is normally only useful
for debugging, eg. profiling individual components with:

    use MasonX::Profiler; # available on CPAN
    Set(@MasonParameters, (preamble => 'my $p = MasonX::Profiler->new($m, $r);'));

=cut

Set(@MasonParameters, ());

=item C<$DefaultSearchResultFormat>

C<$DefaultSearchResultFormat> is the default format for RT search results

=cut

Set ($DefaultSearchResultFormat, qq{
   '<B><A HREF="__WebPath__/Ticket/Display.html?id=__id__">__id__</a></B>/TITLE:#',
   '<B><A HREF="__WebPath__/Ticket/Display.html?id=__id__">__Subject__</a></B>/TITLE:Subject',
   Status,
   QueueName, 
   OwnerName, 
   Priority, 
   '__NEWLINE__',
   '', 
   '<small>__Requestors__</small>',
   '<small>__CreatedRelative__</small>',
   '<small>__ToldRelative__</small>',
   '<small>__LastUpdatedRelative__</small>',
   '<small>__TimeLeft__</small>'});


=item C<$SuppressInlineTextFiles>

If C<$SuppressInlineTextFiles> is set to a true value, then uploaded
text files (text-type attachments with file names) are prevented
from being displayed in-line when viewing a ticket's history.

=cut

Set($SuppressInlineTextFiles, undef);

=item C<DontSearchFileAttachments>

If C<$DontSearchFileAttachments> is set to a true value, then uploaded
files (attachments with file names) are not searched during full-content
ticket searches.

=cut

Set($DontSearchFileAttachments, undef);

=item C<$ChartFont>

The L<GD> module (which RT uses for graphs) uses a builtin font that doesn't
have full Unicode support. You can use a particular TrueType font by setting
$ChartFont to the absolute path of that font. Your GD library must have
support for TrueType fonts to use this option.

=cut

Set($ChartFont, undef);


=item C<@Active_MakeClicky>

MakeClicky detects various formats of data in headers and email
messages, and extends them with supporting links.  By default, RT
provides two formats:

* 'httpurl': detects http:// and https:// URLs and adds '[Open URL]'
  link after the URL.

* 'httpurl_overwrite': also detects URLs as 'httpurl' format, but
  replace URL with link and *adds spaces* into text if it's longer
  then 30 chars. This allow browser to wrap long URLs and avoid
  horizontal scrolling.

See F<share/html/Elements/MakeClicky> for documentation on how to add your own.

=cut

Set(@Active_MakeClicky, qw());

=item C<$DefaultQueue>

Use this to select the default queue name that will be used for creating new
tickets. You may use either the queue's name or its ID. This only affects the
queue selection boxes on the web interface.

=cut

#Set($DefaultQueue, 'General');

=back

=head1 L<Net::Server> (rt-server) Configuration

=over 4

=item C<$StandaloneMinServers>, C<$StandaloneMaxServers>

The absolute minimum and maximum number of servers that will be created to
handle requests. Having multiple servers means that serving a slow page will
affect other users less.

=cut

Set($StandaloneMinServers, 1);
Set($StandaloneMaxServers, 1);

=item C<$StandaloneMinSpareServers>, C<$StandaloneMaxSpareServers>

These next two options can be used to scale up and down the number of servers
to adjust to load. These two options will respect the C<$StandaloneMinServers
> and C<$StandaloneMaxServers options>.

=cut

Set($StandaloneMinSpareServers, 0);
Set($StandaloneMaxSpareServers, 0);

=item C<$StandaloneMaxRequests>

This sets the absolute maximum number of requests a single server will serve.
Setting this would be useful if, for example, memory usage slowly crawls up
every hit.

=cut

#Set($StandaloneMaxRequests, 50);

=item C<%NetServerOptions>

C<%NetServerOptions> is a hash of additional options to use for
L<Net::Server/DEFAULT ARGUMENTS>. For example, you could set
reverse_lookups to get the hostnames for all users with:

C<Set(%NetServerOptions, (reverse_lookups => 1));>

=cut

Set(%NetServerOptions, ());

=back


=head1 UTF-8 Configuration

=over 4

=item C<@LexiconLanguages>

An array that contains languages supported by RT's internationalization
interface.  Defaults to all *.po lexicons; setting it to C<qw(en ja)> will make
RT bilingual instead of multilingual, but will save some memory.

=cut

Set(@LexiconLanguages, qw(*));

=item C<@EmailInputEncodings>

An array that contains default encodings used to guess which charset
an attachment uses if not specified.  Must be recognized by
L<Encode::Guess>.

=cut

Set(@EmailInputEncodings, qw(utf-8 iso-8859-1 us-ascii));

=item C<$EmailOutputEncoding>

The charset for localized email.  Must be recognized by Encode.

=cut

Set($EmailOutputEncoding, 'utf-8');


=back

=head1 Date Handling Configuration

=over 4

=item C<$DateTimeFormat>

You can choose date and time format.  See "Output formatters"
section in perldoc F<lib/RT/Date.pm> for more options.  This option can
be overridden by users in their preferences.
Some examples:

C<Set($DateTimeFormat, { Format => 'ISO', Seconds => 0 });>
C<Set($DateTimeFormat, 'RFC2822');>
C<Set($DateTimeFormat, { Format => 'RFC2822', Seconds => 0, DayOfWeek => 0 });>

=cut

Set($DateTimeFormat, 'DefaultFormat');

# Next two options are for Time::ParseDate

=item C<$DateDayBeforeMonth>

Set this to 1 if your local date convention looks like "dd/mm/yy"
instead of "mm/dd/yy".

=cut

Set($DateDayBeforeMonth , 1);

=item C<$AmbiguousDayInPast>, C<$AmbiguousDayInFuture>

Should an unspecified day or year in a date refer to a future or a
past value? For example, should a date of "Tuesday" default to mean
the date for next Tuesday or last Tuesday? Should the date "March 1"
default to the date for next March or last March?

Set $<AmbiguousDayInPast> for the last date, or $<$AmbiguousDayInFuture> for the
next date.

The default is usually good.

=cut

Set($AmbiguousDayInPast, 0);
Set($AmbiguousDayInFuture, 0);

=back

=head1 Miscellaneous Configuration

=over 4

=item C<@ActiveStatus>, C<@InactiveStatus>

You can define new statuses and even reorder existing statuses here.
WARNING. DO NOT DELETE ANY OF THE DEFAULT STATUSES. If you do, RT
will break horribly. The statuses you add must be no longer than
10 characters.

=cut

Set(@ActiveStatus, qw(new open stalled));
Set(@InactiveStatus, qw(resolved rejected deleted));

=item C<$LinkTransactionsRun1Scrip>

RT-3.4 backward compatibility setting. Add/Delete Link used to record one
transaction and run one scrip. Set this value to 1 if you want
only one of the link transactions to have scrips run.

=cut

Set($LinkTransactionsRun1Scrip, 0);

=item C<$StrictLinkACL>

When this feature is enabled a user needs I<ModifyTicket> rights on both
tickets to link them together, otherwise he can have rights on either of
them.

=cut

Set($StrictLinkACL, 1);

=item C<$PreviewScripMessages>

Set C<$PreviewScripMessages> to 1 if the scrips preview on the ticket
reply page should include the content of the messages to be sent.

=cut

Set($PreviewScripMessages, 0);

=item C<$UseTransactionBatch>

Set C<$UseTransactionBatch> to 1 to execute transactions in batches,
such that a resolve and comment (for example) would happen
simultaneously, instead of as two transactions, unaware of each
others' existence.

=cut

Set($UseTransactionBatch, 0);

=item C<@CustomFieldValuesSources>

Set C<@CustomFieldValuesSources> to a list of class names which extend
L<RT::CustomFieldValues::External>.  This can be used to pull lists of
custom field values from external sources at runtime.

=cut

Set(@CustomFieldValuesSources, ());

=item C<$CanonicalizeRedirectURLs>

Set C<$CanonicalizeRedirectURLs> to 1 to use $C<WebURL> when redirecting rather
than the one we get from C<%ENV>.

If you use RT behind a reverse proxy, you almost certainly want to
enable this option.

=cut

Set($CanonicalizeRedirectURLs, 0);
=item C<$EnableReminders>

Hide links/portlets related to Reminders by setting this to 0

=cut

Set($EnableReminders,1);

=back

=head1 Development Configuration

=over 4

=item C<$DevelMode>

RT comes with a "Development mode" setting. 
This setting, as a convenience for developers, turns on 
all sorts of development options that you most likely don't want in 
production:

* Turns off Mason's 'static_source' directive. By default, you can't 
  edit RT's web ui components on the fly and have RT magically pick up
  your changes. (It's a big performance hit)

 * More to come

=cut

Set($DevelMode, '1');


=back

=head1 Deprecated Options

=over 4

=item C<$AlwaysUseBase64>

Encode blobs as base64 in DB (?)

=item C<$TicketBaseURI>

Base URI to tickets in this system; used when loading (?)

=item C<$UseCodeTickets>

This option is exists for backwards compatibility.  Don't use it.

=back

=cut

1;
