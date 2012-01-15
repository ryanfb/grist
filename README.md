Grist
=====

Grist is a single-serving web app for searching only your own Gists.

![Screenshot](http://dl.dropbox.com/u/360471/Screenshots/8yb60buczv91.png)

Usage
-----

  * [Register your Grist](https://github.com/account/applications/new)
    * Main URL: `http://grist.dev/`
    * Callback URL: `http://grist.dev/auth/github/callback`
  * Copy your secrets into `config.yml`:

        secret:    67ad2341fcde2…
        client_id: b5cf6123…

  * Install Xapian with Ruby bindings (warning: if you're using your Mac's system Ruby, you may need to change permissions so the bindings can be installed):

        brew install --ruby xapian

  * Install gems:

        gem install sinatra sinatra_auth_github haml xapian-fu padrino-helpers

  * Rack 'em (using [Pow](http://pow.cx/)):

        cd ~/.pow && ln -s ~/source/grist

  * Load it up: <http://grist.dev/>
