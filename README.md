## Description

URF Stats is a web application I submitted as an entry to the [Riot Games API Challenge]
(http://na.leagueoflegends.com/en/news/community/contests/riot-games-api-challenge). Since the purpose of the contest
was to do something cool with the Riot API in the wake of the League of Legends April Fool's day [URF mode]
(http://leagueoflegends.wikia.com/wiki/Ultra_Rapid_Fire), the app displays various match statistics like champion win
rates and item purchases aggregated over 12 days of URF.

While the collected statistics are interesting in themselves (see [www.urfstats.io](http://www.urfstats.io/)), the
project is also a technical reference for advanced use cases of the [Ember.js](http://emberjs.com/) JavaScript framework
connected to a [Ruby on Rails](http://rubyonrails.org/) backend. In the rest of the README, I discuss how to put
together such a system, broken down into four functional areas.

## Data Collection

For the collection, persistence, and analysis of match information, we chose the background job processor [Sidekiq]
(http://sidekiq.org/), which conveniently ran off of the app's Rails codebase. In the first stage, the
[`SaveMatchesWorker`](https://github.com/carsomyr/urf_stats/blob/master/lib/urf_stats/workers/save_matches_worker.rb)
job read the randomized URF match ids and fetched match JSON using a [bespoke Riot API REST client]
(https://github.com/carsomyr/urf_stats/blob/master/lib/riot/api/client.rb) built on top of [Faraday]
(https://github.com/lostisland/faraday). The results were persisted to the database as [`Riot::Api::Match`]
(https://github.com/carsomyr/urf_stats/blob/master/db/schema.rb#L65-71)es. In the second stage, the [`StatWorker`]
(https://github.com/carsomyr/urf_stats/blob/master/lib/urf_stats/workers/stat_worker.rb) job aggregated individual
matches into [`Stat`](https://github.com/carsomyr/urf_stats/blob/master/db/schema.rb#L99-118)s quantized by region and
day. As a side effect of computing summary statistics, a bunch of [associated quantities]
(https://github.com/carsomyr/urf_stats/blob/master/lib/urf_stats/champion_accumulator.rb#L63-64) like champion wins and
item purchases were also saved.

## API Server

We used Ruby on Rails as the foundation for the API server, one that would render JSON for consumption by an Ember.js
app. Since the project involved a completely JavaScript frontend, it had no Rails views to speak of; instead, the
complex portions involved data modeling and writing lengthy database queries using a combination of the
[ActiveRecord ORM](http://guides.rubyonrails.org/active_record_basics.html) and [Arel](https://github.com/rails/arel).
We relied on the [ActiveModelSerializers](https://github.com/rails-api/active_model_serializers) library for
transforming models and their associations into JSON consumable by the [Ember Data](https://github.com/emberjs/data)
library. This would be analogous to the Riot API's data transfer objects, with [sideloading]
(http://guides.emberjs.com/v1.11.0/models/the-rest-adapter/) and polymorphism as advanced features specifically meant
to deal with associations.

## Ember.js App

The purpose of the Ember.js frontend app was to enable a high level of user interactivity while remaining robust.
Although lower-level libraries like jQuery could in theory have had the same effect, in practice it's not possible to
manually keep views in sync with user inputs and browser events. In particular, the app showcases the following
interactions:

1.  Changing the region, date, or sort order sets their corresponding button state to `active` (depressed). Furthermore,
    the app's query parameters will change and cause it to request fresh, parameterized models from the server.
2.  Typing in champion and item names will initiate requests to the server and update search results in real time.
3.  Narrowing champion search results to exactly one will display splash art for that champion.

In creating the app, we benefited a great deal from reusability: A building block like [`StaticEntityImageComponent`]
(https://github.com/carsomyr/urf_stats/blob/master/app/assets/javascripts/components/static_entity_image_component.coffee)
wrapped every champion or item's image and intelligently linked the appropriate wiki page.

Stylistically, we applied [Twitter Bootstrap](http://getbootstrap.com/)'s classes and responsive grid to achieve a clean
look and decent usability on mobile devices. We placed a particular emphasis on the responsive aspect and ensured that
[even data tables collapsed gracefully]
(https://github.com/carsomyr/urf_stats/blob/master/app/assets/stylesheets/data_table.less) on small screens.

To assemble and compress the numerous JavaScript and CSS assets, we made extensive use of the [Rails asset pipeline]
(http://guides.rubyonrails.org/asset_pipeline.html). In particular, [RequireJS](http://requirejs.org/) and the
[requirejs-rails](https://github.com/jwhitley/requirejs-rails) library were used to synthesize the Ember app and its
constituent model, view, controller, and route files into a single, minified, production-optimized JavaScript file.

## Deployment

The app at [www.urfstats.io](http://www.urfstats.io/) is running in the Amazon Web Services (AWS) cloud. We use EC2
for compute (on a `c3.large` instance), Route 53 for DNS management (whose name servers answer for `urfstats.io`), and
EBS for snapshotting database files and transferring them across instances. To provision a new machine with the
necessary configuration for supporting Rails and Sidekiq background jobs, we used [Chef](https://www.chef.io/) combined
with proprietary cookbooks and data management techniques. On top of that configured state, [Capistrano]
(http://capistranorb.com/) was used for repeat deployments.

## Testing

To test the app:

1.  Change into the project root directory.
2.  Run `bundle install`.
3.  Copy the `config/*.sample.yml` files to `config/*.yml` and fill in the appropriate values.
4.  Run `createdb -- urf_stats` (assuming PostgreSQL).
5.  Run `bundle exec rake db:migrate`.
6.  Run `bundle exec rake db:seed` (this populates the database with static champion, item, and rune/mastery data).
7.  Run `bundle exec rake` for RSpec tests.

To try the app locally, run `bundle exec rails s`.

## License

    Copyright 2015 Roy Liu

    Licensed under the Apache License, Version 2.0 (the "License"); you may not
    use this file except in compliance with the License. You may obtain a copy
        of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
    License for the specific language governing permissions and limitations
    under the License.
