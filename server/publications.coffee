root = exports ? this

collections = {'users': Meteor.users}

Meteor.startup ->
  set_up_collection = (name, collection) ->
    methods = {}
    methods["admin_#{name}_insert"] = (doc) ->
      return unless @userId
      return unless Roles.userIsInRole(this.userId, ['admin'])
      collection.insert(doc)

    methods["admin_#{name}_update"] = (id, update_dict) ->
      return unless @userId
      return unless Roles.userIsInRole(this.userId, ['admin'])
      if collection.findOne(id)
        collection.update(id, update_dict)
      else
        id = collection.findOne(new Meteor.Collection.ObjectID(id))
        collection.update(id, update_dict)

    methods["admin_#{name}_delete"] = (id, update_dict) ->
      return unless @userId
      return unless Roles.userIsInRole(this.userId, ['admin'])
      if collection.findOne(id)
        collection.remove(id)
      else
        id = collection.findOne(new Meteor.Collection.ObjectID(id))
        collection.remove(id)

    Meteor.methods methods

    publish_to_admin "admin_#{name}", ->
      try
        collection.find()
      catch e
        console.log e
    Collections.insert {name} unless Collections.findOne {name}

    for key, value of YTCollections
      set_up_collection(key, value)

publish_to_admin = (name, publish_func) ->
  Meteor.publish name, ->
    if (Roles.userIsInRole(this.userId, ['admin']))
      publish_func()
    else
      this.stop()

# publish our own internal state
publish_to_admin "admin", -> Collections.find()