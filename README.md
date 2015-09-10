# Building an API with Rails 5

## Learning Objectives

* Understand the goal of Rails-API and why it will be incorporated into Rails 5
* Compare and Contrast Rails 5 API with other server-side APIs
* Use Rails 5 API to build a JSON rendering API
* Learn how to configure API to integrate with client applications

## Opening Framing

Over the last few years thanks to rise in popularity in front-end frameworks such as Backbone.js and Angular.js, the number of Single Page Applications (SPAs) are on the rise. These rich client-side applications primarily work by consuming data from external APIs, however developing, configuring, and maintaing these sources on the server-side can often be tedious and error-prone.

Enter Rails 5 soon to be fully integrated Rails-API!

Today we will be building a back-end API with the help of Rails 5 API and integrate it with an existing backbone app(not at all like PbjRadio)

Some questions to keep in mind along the way:

* What is Rails 5 and Rails-API?
* Why would you use Rails as an API?
* What are the alternatives?
* How does a traditional Rails app compare to one configured to serve as an API?
* What are the steps to take a full Rails app and turn it into an API?

### Rails-API and Rails 5
Rails-API Goal:
> Rails API aims to facilitate the implementation of API only Rails projects, where only a subset of Rails features are available. A Rails API application counts with lightweight controllers, a reduced middleware stack and customized generators.

#### Why Rails?
 The first question a lot of people have when thinking about building a JSON API using Rails is: "isn't using Rails to spit out some JSON overkill? Shouldn't I just use something like Express?"

 The reason most people use Rails is that it provides a set of defaults that allows us to get up and running quickly without having to make a lot of trivial decisions.

Let's take a look at some of the things that Rails provides out of the box that are still applicable to API applications:
* Active Record: Sequelize anyone? Didn't think so.
* Security: Rails detects and thwarts IP spoofing attacks and handles cryptographic signatures in a timing attack aware way. Don't know what an IP spoofing attack or a timing attack is? Exactly.
* Parameter Parsing: Want to specify your parameters as JSON instead of as a URL-encoded String? No problem. Rails will decode the JSON for you and make it available in params. Want to use nested URL-encoded params? That works too.
* Basic, Digest and Token Authentication: Rails comes with out-of-the-box support for three kinds of HTTP authentication.
* Generators, Gems, and Plugins, and many other Rails goodies.

You can find more answers to any questions as well as advanced discussion on the merits of rails at the Rails-API Gem's [official github page](https://github.com/rails-api/rails-api)

## Implementing a new Rails API
Let's walk through how to easily get an API up and running using Rails 5 new API feature.

Once Rails 5 is released, creating an API only application will be accomplished by running:

      rails new <application-name> --api

But for now we have to use the latest available Rails Source and configure it to our needs.

If at anytime you want to look at the solution, click [here](https://github.com/nolds9/rails-5-api-radio)

### Getting Started

* We are going to need the latest Rails source so lets clone its Github repo onto our computer:

          git clone git://github.com/rails/rails.git

* Now lets move into that directory and install dependencies:
  ```
  cd rails
  bundle install
  ```


### Rails New (WE DO)

* In order to have our generated project pointing to our local copy of the Rails source code, we need to run this command in the following manner:

        bundle exec railties/exe/rails new ../my_radio_api --api --edge -d postgresql

   It’s a good idea to specify a path for the generated project, so we avoid creating the Rails API application inside the Rails source code folder.


### Compare and Contrast (YOU DO)

* Moving out of the rails source and into our API, lets see what the command generated:
      ```
      cd ..
      cd my_radio_api
      ```

   Opening our directory in our text editor, we can poke around our files and inspect any differences


### Major Differences
* The Gemfile
  > We can notice that stuff related with asset management and template rendering is not longer present (jquery-rails and turbolinks among others). In addition, the active_model_serializers is included by default because it will be responsible for serializing the JSON responses returned by our API application.

* Controllers/application_controller.rb
> The api_only config option makes posible to have our Rails application working excluding those middlewares and controller modules that are not needed in an API only application.

* Config/Application.rb
> Please note that ApplicationController inherits from ActionController::API. Remember that Rails standard applications have their controllers inheriting from ActionController::Base instead.

## Break (Questions?)

### Creating our Sweet Radio App
  The main purpose of our API application is to serve as a backend storage for our list of Songs.
  For our radio app, we will need to define a Song model with the following attributes:
    * title:string
    * audio_url:string
    * artist:string
    * genre:string

* Lets use one of Rails 5 API's new generators to build a scaffold with all necessary components

        bin/rails g scaffold song title audio_url artist genre


 (Note) We need to make sure all rails commands run the latest Rails source code in our computer, so we must run the executables from the bin folder (otherwise, the scaffold would use the rails code from an installed rails gem in the system).

### Compare and Contrast (YOU-DO)

- What files did this scaffold generate for us?
- What are the main differences?


### Comparisons
  * SongsController
  >  If we compare this controller with one generated for a regular Rails application, we would find some differences. First of all, the actions new and edit are not included. That’s because these actions are used to render the html pages containing the forms where users fill the data to be added or modified in the system. Of course, it does not make sense in an API because this application is not longer responsible for rendering html pages.

  * Routes
    > The Config/routes.rb file now includes resources :songs and if we were to run: rake routes we would see that new and edit routes are excluded.

  * Views
  > Where are the views? Exactly, no template files are generated when scaffolding a new resource in our Rails API application.

  * Serializers
  > Our scaffold generated a SongSerializer class and provided the list of attributes from our Song model to include in the responses.

### Final Touches
* We need to make sure to migrate our database so: ```rake db:migrate```
* Add these seeds to the seed file:
    ```
    require 'httparty'

    Song.destroy_all

    artists = [
      "nosaj+thing",
      "flume",
      "kendrick+lamar",
      "beatles",
      "daft+punk",
      "drake",
      "killers",
      "m83",
      "ratatat"
    ]

    artists.each do |artist|
      # make all the assumptions!
      results = JSON.parse(HTTParty.get("https://itunes.apple.com/search?term=#{artist}"))["results"];
      results[0...10].each do |result|
        puts result["trackName"]
        Song.create({
          title: result["trackName"],
          audio_url: result["previewUrl"],
          album_art: result["artworkUrl100"],
          artist: result["artistName"],
          genre: result["primaryGenreName"]
        })
      end
    end
  ```

* Add httparty gem to gemfile and: ```bundle install``` then ```rake db:seed```

* Test
  >  Congratulations! At this point, we have implemented with almost zero effort a working backend application. We can run bin/rails s to start the web server and test our API with the help of Postman

### Integrating with our Backbone App

* The backbone app can be found [here](https://github.com/nolds9/MyRadio_backbone), fork and clone and follow install instructions.

* Allow for CSO with Rack Cors gem
>  Our last outstanding task is to configure the cross origin policy to make the communication between both components possible. This is necessary when the backend and the client components are in different domains. Uncomment line in gemfile, bundle install, and configure the cors.rb file in config/initializers

* Run our API's server and then in our Front-End client's repo we can run another server at the port specified in the configuration of the cors.rb file and visit that port on localhost to view app

## Closing
 I think this is pretty amazing, we were able to get a fully functional JSON serving API up and running with relative ease.
 Rails 5 promises to be packed with a lot of new exciting features, but I think this has to be one of most monumental.
 Now Go Forth and Conquer with Rails 5 API!

## Resources
* [Rails Source](https://github.com/rails/rails)
* [Rails 5 API and Backbone Tutorial](http://wyeworks.com/blog/2015/6/11/how-to-build-a-rails-5-api-only-and-backbone-application)
* [Rails Offical Blog](http://weblog.rubyonrails.org/)
* [What's New in Rails 5](http://www.sitepoint.com/whats-new-rails-5/)
