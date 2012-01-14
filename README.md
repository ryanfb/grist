Grist
=====

  * [Register your Grist](https://github.com/account/applications/new)
    * Main URL: `http://grist.dev/`
    * Callback URL: `http://grist.dev/auth/github/callback`
  * Copy your secrets into `config.yml`:

        secret:    67ad2341fcde2…
        client_id: b5cf6123…

  * Install Xapian with Ruby bindings:

        brew install --ruby xapian

  * Install gems:

        gem install sinatra sinatra_auth_github haml xapian-fu

  * Rack 'em:

        cd ~/.pow && ln -s ~/source/grist

  * Load it up: <http://grist.dev/>
