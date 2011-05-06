Summary and Mission
===================

K3cms is a complete Content Management System (CMS) written from scratch to take full advantage of Rails 3.

The mission of K3cms is to provide a framework to quickly launch websites that can be easily managed by non-technical end users while providing advanced features for software developers and graphics professionals.

Features
========

1. **No “admin back-end”**. You can do all your editing directly on the front-end, editing your site while seeing it as it really appears to the public. No need for a separate admin dashboard.
2. **In-place editing**. Edit any visible text, anywhere on your site. Just click and start editing!
3. **Simple, wiki-like process for creating new pages**. Just add a link to whatever URL you would like your new page to have, click on the link, and start editing &mdash; the new page will automatically have the URL you entered.
5. **Add more features with extensions**. A growing library of extensions allow you to quickly and easily customize your site add add features not provided by the core system.
4. **Use only what you need**. K3cms has a very light-weight core and is built upon Ruby’s package system ([RubyGems](http://rubygems.org/)), so you can include just the gems and features your application needs and omit the rest.
6. **Developer friendly**. Well-maintained, clean code; consistent conventions; and comprehensive developer documentation make it a pleasure to develop with and extend the K3cms framework.

Planned features:

1. Built in i18n support.
2. Site-wide editing timeline, allowing users to easily publish site changes as a batch.
3. An advanced theming engine.
4. Drag and drop widgets.
5. A RESTful API interface to all core functionality and extensions.

K3cms actually consists of several different gems. By requiring the `k3cms` gem, you automatically require all of the necessary dependency gems. These "core" gems are as follows:

* `k3cms_core`
* `k3cms_authorization`
* `k3cms_inline_editor`
* `k3cms_pages`
* `k3cms_ribbon`

These core gems are maintained in a single [repository](http://github.com/k3integrations/k3cms) and documented in a single set of online documentation.

Installing and Getting Started
==============================

You can either:

* use the `k3cms` command to generate a _new_ application for you,
* _or_ if you have an existing application to which you want to add the K3cms, simply add the `k3cms` gem to your `Gemfile` (and make a few changes as outlined below).

Tutorial: Generating an application with the `k3cms` command
------------------------------------------------------------

This is the easiest option to get you up and running with a working k3cms application quickly.

First install the `k3cms` gem, if you haven't already:

    gem install k3cms

Then simply run this to generate your app:

    k3cms app_name

That's it! Now try out your new app. Start your development web server with:

    rails server

and go to <http://localhost:3000/> in your browser. You might be surprised to find that the home page says "Page not found". But don't worry, there's a good reason for that: it says "Page not found" because you haven't _created_ a home page yet. So let's create a home page now.

But first, you'll need to create a user account, since `k3cms_trivial_authorization` (the default authorization option) requires you to be logged in before you can create or edit pages. So go to <http://localhost:3000/users/sign_up> now and create an account.

Now that you're logged in and back at the [Home page](http://localhost:3000/), click "Start editing" and then click "create it now". That was easy! Now you have a home page and can immediately start editing it.

About the `k3cms` command
--------------------------------------------------

This command accepts all the same options as the `rails new` command. You can run `rails new --help` for a list of those options. Any options for `rails new` will automatically be passed on to the  `rails new` command.

In addition to the options that `rails new` recognizes, the `k3cms` command recognizes a few additional options:

    [--gems/--extra-gems=one two three]        # A space-seperated list of extra gems to add to the Gemfile and install (for example, '--gems=k3cms_blog k3cms_s3_podcast').
    [--auth/--authentication=AUTHENTICATION]   # Which authentication library to install. Options are 'devise' or 'none'.
                                               # Default: devise
    [--authorization=AUTHORIZATION]            # Which authorization library to use. Known options are 'k3cms_trivial_authorization', 'k3cms_spree_authorization'.
                                               # Default: k3cms_trivial_authorization
    [--k3cms-edge]                             # Use the latest edge version from git://github.com/k3integrations/k3cms.git instead of from rubygems.org

By default, it will assume you want to use Devise for authentication and will install it for you. If you'd rather set up a different authentication system, then just pass `--auth none` and you can set up authentication manually.


Adding to an existing application
---------------------------------

This will basically walk you through all the steps that the `k3cms` generator does for you automatically if you use the `k3cms` command to create a new app. There are a few steps involved, but it's really not too difficult to add K3cms to any Rails 3.x application!

You must have a `User` ActiveRecord model defined in `app/models` in order to use K3cms.  You can use the `devise` gem for this -- or any other authentication system that provides a User model.  If you want to use devise, just follow its install directions, but you do not need to create a `root_path` route.

    <pre>
    rails generate devise:install
    rails generate devise User
    </pre>

Once you've taken care of that prerequisite, start actually installing k3cms by adding the `k3cms` gem to your existing application's `Gemfile`:

    gem 'k3cms'

(That will use the latest gem released on rubygems.org. If you want to use the latest edge version, you can use `gem 'k3cms', :git => 'git://github.com/k3integrations/k3cms.git'` instead.)

You'll also want to choose one of the available authorization gems. `trivial_authorization` is a good one to start with if you don't already know you'll need something more complex.

    gem 'k3cms_trivial_authorization'

Install all the gems from your `Gemfile`:

    bundle install

Now copy all of the necessary migrations and assets from each K3cms gem referenced in your `Gemfile` with this command:

    rake k3cms:install

Now run the migrations that were just copied into the `db/` directory and prepare your database:

    rake db:migrate
    rake db:seed

Also, you will need to add a few things to your layout...

You must have jQuery installed and included in your layouts. In your `config/application.rb`, we recommend you change the `:default` javascript_expansion to this:

    config.action_view.javascript_expansions[:defaults] = %w(jquery rails)

Somewhere within your `<head>` tag, you need to add these lines:

    <%= javascript_include_tag :defaults %>
    <%= hook :head %>%>

Somewhere within your `<body>` tag, you need to add this line:

    <%= hook :top_of_page %>

And wherever you want the ribbon to appear in the document, you need to add this:

    <%= k3cms_ribbon %>

Also, add this to the User class:

    include K3cms::Authorization::RealUser

If you have any trouble getting things set up, you can always refer to the official [demo_app](http://github.com/k3integrations/k3cms_demo_app) and compare it with how your app is set up.


Working with the edge source
============================

While normally it is recommended to use the latest stable gem release from <http://rubygems.org/>, there might be times when you need the latest and greatest features that are only available in the edge version (which hasn't been published as a gem yet). This is also what you need to use if you are going to work on a bug fix or enhancement to the K3cms _core_ (not strictly necessary if you are developing an extension).

First, grab a copy of the latest (edge) version of K3cms from GitHub:

    > git clone git://github.com/k3integrations/k3cms.git

[TODO: finish this section]

Running Tests
-------------

If you want to run all the tests across all the core K3cms gems, then you would type something like this:

    > cd k3cms
    > rake spec       # This will run spec tests for all the gems
    > rake cucumber   # This will run cucumber tests for all the gems
    > rake            # This will run both spec and cucumber tests for all the gems

Each gem contains its own set of tests. For each gem that you want to run the tests for (each directory in the [k3cms repository](http://github.com/k3integrations/k3cms)), you need to do a quick one-time creation of a test application before you can run the tests. For example, to run the tests for the 'core' gem:

    > cd core
    > rake test_app
    > rake spec
    > rake cucumber
    > rake            # This will run both spec and cucumber tests for the gem

    # If you want to run specs for only a single spec file:
    > bundle exec rspec spec/lib/k3cms/file_utils_spec.rb

    # If you only want to run a single example from a spec file, you can specify it either with a line number or the name of the example:
    > bundle exec rspec spec/lib/k3cms/file_utils_spec.rb:10
    > bundle exec rspec spec/lib/k3cms/file_utils_spec.rb -e 'example name'

    # If you want to run a single cucumber feature:
    > bundle exec cucumber features/manage_pages.feature --require features

    # If you want to only run a particular scenario in a feature then specify a line number too:
    > bundle exec cucumber features/manage_pages.feature:8 --require features


Contributing
============

K3cms is an open source project. We welcome your contributions.

[TODO: contribution guidlines]

License
=======

Copyright 2010-2011 [K3 Integrations, LLC](http://www.k3integrations.com/)

K3cms is free software, distributed under the terms of the [GNU Lesser General Public License](http://www.gnu.org/copyleft/lesser.html), Version 3 (see License.txt).
