# plushu

plushu is a shell, intended for use as a dedicated SSH user, whose commands are
entirely specified by installed plugins.

It is inspired by the interface used by [Dokku][] to create a Heroku-in-a-box
server for building and running web apps.

[Dokku]: https://github.com/progrium/dokku

## Installing plushu

**To do all this in one line: `sudo bash <(curl meta.sh/setup/plushu)`**

This is the standard flow for installing plushu on a server:

### Step 1: Get the core

Clone the plushu repository into a new directory that will be used as the home
directory for the plushu user. To put it in the standard home location:

```bash
sudo git clone git@github.com:plushu/plushu /home/plushu
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

Note that, by default, plushu does *not* discriminate between authorized keys
in any way. If you need this (for instance, to have administrative and normal
users), you should install a plugin and edit authorized_keys accordingly.

## Using plushu

On installation, plushu creates a user whose login shell is the base plushu
script. As the plushu script is not interactive, you use
`ssh plushu@example.com` followed by arguments as your plushu command.

So, for example, if you would use this on the server:

```bash
plushu help
```

You would use this on the client:

```bash
ssh plushu@example.com help
```
