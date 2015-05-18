# plushu
[![Gitter](https://badges.gitter.im/Join Chat.svg)](https://gitter.im/plushu/plushu?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

plushu is a shell, intended for use as a dedicated SSH user, whose commands are
entirely specified by installed plugins.

It is inspired by the interface used by [Dokku][] to create a Heroku-in-a-box
server for building and running web apps.

[Dokku]: https://github.com/progrium/dokku

## Prerequisites

Although it's not a strict requirement, plushu is meant to be used with Git
installed, as this allows plushu to install plugins via `git clone` and
determine versions with `git describe`.

## Installing plushu

**To do all this in one line: `sudo bash <(curl meta.sh/setup/plushu)`**

This is the standard flow for installing plushu on a server:

### Step 1: Get the core

Clone the plushu repository into a new directory that will be used as the home
directory for the plushu user. To put it in the standard home location:

```bash
sudo git clone https://github.com/plushu/plushu /home/plushu
```

### Step 2: Set up the user

Once you have the plushu root on your system, run the installer script to
create the `plushu` user and do other integration.

```bash
sudo /home/plushu/install.sh
```

By default, install.sh will:

- use the directory containing install.sh as PLUSHU_ROOT
- create a user named "plushu" (if not already present) with the `plushu` shell
  script as its login shell and PLUSHU_ROOT as its home
- set the plushu user as the owner of PLUSHU_ROOT
- Make ~/.ssh and ~/.ssh/authorized_keys for the plushu user, if they don't
  already exist
- create a link to the `plushu` shell script in /usr/local/bin
- Set the clone's git repo to ignore all unrecognized files (so adding files
  won't affect the status of the working tree)

## Configuring plushu

### Adding authorized keys

Like Dokku or GitHub, you'll need to upload authorized public keys for each
user you want to have access to plushu.

Assuming you are already set up with an identity for root access, you can add
authorized keys for plushu with a command like:

```bash
ssh root@example.com "cat >>/home/plushu/.ssh/authorized_keys" <~/.ssh/id_rsa.pub
```

By default, plushu does *not* discriminate between authorized keys in any way.
If you need this (for instance, to have administrative and normal users based
on the key being used), you should install a plugin and edit authorized_keys
accordingly.

Note that, if you don't disable port forwarding, agent forwarding, or X11
forwarding globally, you will likely want to do it for each key in
authorized_keys. See next section.

### Restricting ssh

By default, `sshd` allows users to forward ports, agent credentials, and
streams from the local machine. There are also options, disabled by default,
to allow X11 forwarding and device tunneling. These features will allow users
to bypass the `plushu` shell and perform actions that you would likely
otherwise want restricted.

To change these at the system configuration level, you must edit
`/etc/ssh/sshd_config` to set these options (optionally under a
`Match User plushu` line to limit the restictions to only the `plushu` user):

```
AllowTcpForwarding no
AllowStreamLocalForwarding no
AllowAgentForwarding no
X11Forwarding no
PermitTunnel no
```

This is the recommended way to restrict the `plushu` user, as it is managed by
files the `plushu` user does not normally have write access to (and it appears
to be the only way to restrict access to StreamLocal forwarding).

You may also use options before each key in the `authorized_keys` file to
disable port, agent, and X11 forwarding, as well as preventing execution of
`.ssh/rc` if present:

```
no-port-forwarding,no-agent-forwarding,no-X11-forwarding,no-user-rc ssh-rsa (etc...)
```

This can be used if editing the global `sshd` configuration is not an option
for whatever reason, or if you only want to restrict these features for certain
keys, or if you just want to specify restrictions redundantly.

## Accessing plushu

On installation, plushu creates a user whose login shell is the base plushu
script. You use `ssh -t plushu@example.com` followed by arguments as your
plushu command. (The '-t' option makes it so that SSH requests a full TTY
when executing the command: you don't strictly need it if your commands aren't
interactive, but it's a good basis

So, for example, if you would use this on the server:

```bash
plushu help
```

You would use this on the client:

```bash
ssh -t plushu@example.com help
```

See https://github.com/plushu/plushu/wiki/Client for ways you can create a
shortcut for this.

## Usage

To get the list of plugins installed in plushu:

```bash
plushu plugins
```

To read the README for any given plugin:

```bash
plushu help <plugin>
```

To get Plushu's version:

```bash
plushu --version
```

(The short alias `-v` works as well.)

Plushu reads its version based on the Git revision currently checked out, so it
will not work if PLUSHU_ROOT is not a Git repository.
