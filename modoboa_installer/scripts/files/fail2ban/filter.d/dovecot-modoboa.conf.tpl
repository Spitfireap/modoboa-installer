# Fail2Ban filter Dovecot authentication and pop3/imap server
#
# Author: Martin Waschbuesch
#         Daniel Black (rewrote with begin and end anchors)
#         Martin O'Neal (added LDAP authentication failure regex)
#         Sergey G. Brester aka sebres (reviewed, optimized, IPv6-compatibility)

[INCLUDES]

before = common.conf

[Definition]

_auth_worker = (?:dovecot: )?auth(?:-worker)?
_daemon = (?:dovecot(?:-auth)?|auth)

prefregex = ^%(__prefix_line)s(?:%(_auth_worker)s(?:\([^\)]+\))?: )?(?:%(__pam_auth)s(?:\(dovecot:auth\))?: |(?:pop3|imap|managesieve|submission)-login: )?(?:Info: )?<F-CONTENT>.+</F-CONTENT>$

failregex = ^authentication failure; logname=<F-ALT_USER1>\S*</F-ALT_USER1> uid=\S* euid=\S* tty=dovecot ruser=<F-USER>\S*</F-USER> rhost=<HOST>(?:\s+user=<F-ALT_USER>\S*</F-ALT_USER>)?\s*$
            ^(?:Aborted login|Disconnected|Remote closed connection|Client has quit the connection)(?::(?: [^ \(]+)+)? \((?:auth failed, \d+ attempts(?: in \d+ secs)?|tried to use (?:disabled|disallowed) \S+ auth|proxy dest auth failed)\):(?: user=<<F-USER>[^>]*</F-USER>>,)?(?: method=\S+,)? rip=<HOST>(?:[^>]*(?:, session=<\S+>)?)\s*$
            ^pam\(\S+,<HOST>(?:,\S*)?\): pam_authenticate\(\) failed: (?:User not known to the underlying authentication module: \d+ Time\(s\)|Authentication failure \(password mismatch\?\)|Permission denied)\s*$
            ^[a-z\-]{3,15}\(\S*,<HOST>(?:,\S*)?\): (?:unknown user|invalid credentials|Password mismatch)
            <mdre-<mode>>

mdre-aggressive = ^(?:Aborted login|Disconnected|Remote closed connection|Client has quit the connection)(?::(?: [^ \(]+)+)? \((?:no auth attempts|disconnected before auth was ready,|client didn't finish \S+ auth,)(?: (?:in|waited) \d+ secs)?\):(?: user=<[^>]*>,)?(?: method=\S+,)? rip=<HOST>(?:[^>]*(?:, session=<\S+>)?)\s*$

mdre-normal = 

# Parameter `mode` - `normal` or `aggressive`.
# Aggressive mode can be used to match log-entries like:
#   'no auth attempts', 'disconnected before auth was ready', 'client didn't finish SASL auth'.
# Note it may produce lots of false positives on misconfigured MTAs.
# Ex.:
# filter = dovecot[mode=aggressive]
mode = normal

ignoreregex = 

journalmatch = _SYSTEMD_UNIT=dovecot.service

datepattern = {^LN-BEG}TAI64N
              {^LN-BEG}

# DEV Notes:
# * the first regex is essentially a copy of pam-generic.conf
# * Probably doesn't do dovecot sql/ldap backends properly (resolved in edit 21/03/2016)
#
# Author: Martin Waschbuesch
#         Daniel Black (rewrote with begin and end anchors)
#         Martin O'Neal (added LDAP authentication failure regex)
#         Sergey G. Brester aka sebres (reviewed, optimized, IPv6-compatibility)
