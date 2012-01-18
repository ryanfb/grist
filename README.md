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

License (MIT)
-------------
Copyright © 2012 Ryan Baumann.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.