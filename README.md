# Act_as_group

## Philosophy

This gem facilitates massive operations in a REST style. To this aim, when a massive operation is required, a new resource is created called `Group`, the goal of this model is two-fold: represents the resources which are going to be updaded/destroyed and by whom is performing the action.

For instance, let suppose that we have an array of Posts that need to be destroyed. The naive aproach would be sth like:

```
DELETE /posts/1
DELETE /posts/2
DELETE /posts/3
...
```

But when the number of posts is very large, this approach could hamper the overall performance of our application. However, this gem solves this issue first creating a group with the ids of these posts:

```
POST /posts/groups

ids=1,2,3,...&owner_id=myself
```

Then, after creating the group is possible to perform the very same operation in all the ids forming the group. For instance, let suppose that all the aforementioned posts need to be destroyed, this operation could be performed in a very straightforward way:

```
DELETE /posts/groups/:id_group
```

As the number of posts could be very large, the operation of destruction is performed in a background style. Similarly, if all these resources want to be updated:

```
PUT /posts/groups/:id_group

read=true
```

## Installation

Put this in your Gemfile:

```
gem 'act_as_group'
```

Run the installation generator with:

```
rails generate act_as_group:install
```

This will install the act_as_group initializer into `config/initializers/act_as_group.rb`.

## Configuration

All the configuration for this gem is contained into `config/initializers/act_as_group`.

* __orm__: enables to define which orm should be used to persist the `Group` model. Default: `cache`
* __background__: which backend should be used to perform the background processing. Default: `delayed_job`. Until the moment only sidekiq and delayed_job are supported.
* __destroy_resource__: which method should be called to destroy each one of the resources. Default: `destroy`
* __update_resource__: which method should be called to update each one of the resources. Default: `update`. It should be noted that it receives one argument with a hash.
* __authorize?__: its goal is two-fold. First, it authorizes the creation/update/destruction of the model `Group`. Second, it also authorizes the operation of update/destruction on each one of the resource. It is a `proc` executed in the context of your controller~s resource, thus it is possibles to access your defined varibles (such as `current_user`). This `proc` receives two arguments: the resource and the action perfomed on it.
* __process_errors__:

## Routes
