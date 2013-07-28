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


  save_collections = (meh, collections_db) ->
    collection_names = (col.collectionName for col in collections_db \
      when (col.collectionName.indexOf "system.") isnt 0 and
           (col.collectionName.indexOf "admin_") isnt 0)

    # fucking closures bro
    collection_names.forEach (name) ->
      unless name of collections
        try
          collections[name] = new Meteor.Collection(name)
        catch e
          # fuck bitches, get collections
          for key, value of root
            if name == value._name
              collections[name] = value
          console.log e

        set_up_collection(name, collections[name])

  fn = Meteor.bindEnvironment save_collections, (e) ->
    console.log e.stack
  Meteor._RemoteCollectionDriver.mongo.db.collections fn

publish_to_admin = (name, publish_func) ->
  Meteor.publish name, ->
    if (Roles.userIsInRole(this.userId, ['admin']))
      publish_func()
    else
      this.stop()

# publish our own internal state
publish_to_admin "admin", -> Collections.find()