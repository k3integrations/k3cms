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

* install the `k3cms` gem first and then use the `k3cms` command to generate a new site for you,
* _or_ if you have an existing application to which you want to add the K3cms, you can simply add the `k3cms` gem to your `Gemfile`.

Prerequisites:

* You must already have a User ActiveRecord model defined in app/models.  You can use the devise gem for this.  (Follow its install directions, but you do not need to create a #root_path route if you use the devise authorization driver mentioned below.)
* You must have jQuery installed and included in all your layouts

Adding to an existing application
---------------------------------

Start by adding the gem to your existing Rails 3.x application's `Gemfile`

    gem 'k3cms'

You'll also want to choose one of the available authorization gems. `trivial_authorization` is a good one to start with if you don't already know you'll need something more complex.

    gem 'k3cms_trivial_authorization'

Install all the gems from your `Gemfile`:

    bundle install

Now copy all of the necessary migrations and assets from each K3cms gem referenced in your `Gemfile` with:

    rake k3cms:install

Now run the migrations that were just copied into db/ and prepare your database:

    rake db:migrate
    rake db:seed

Also... You will need to add a few things to your layout.

Somewhere within your <head> tag, you need to add these lines:
    <%= javascript_include_tag :defaults %>
    <%= hook :inside_head %>%>

Somewhere within your <body> tag, you need to add this line:
    <%= hook :top_of_page %>

And wherever you want the ribbon to appear in the document, you need to add this:
    <%= k3cms_ribbon %>

Check out the demo_app for an example.

And, add this to the User class:

    include K3cms::Authorization::RealUser

Start your server with:

    rails server

Now try it out! Go to <http://localhost:3000> to start using your new (or existing) application.


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
    > rake test_app   # [TODO: doesn't exist yet]
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

    # If you want to only run a particular scenario then specify a line number:
    > bundle exec cucumber features/manage_pages.feature:8 --require features


Contributing
============

K3cms is an open source project. We welcome your contributions.

[TODO: contribution guidlines]

License
=======

Copyright 2010-2011 K3 Integrations, LLC

K3cms is free software, distributed under the terms of the [GNU Lesser General Public License](http://www.gnu.org/copyleft/lesser.html), Version 3 (see License.txt).
