Meteor.subscribe 'admin'

setup_collection = (collection_name) ->
  subscription_name = "admin_#{collection_name}"
  inspector_name = "inspector_#{collection_name}"

  unless window[inspector_name]
      window[inspector_name] = YTCollections[collection_name]

  Meteor.subscribe subscription_name
  Session.set("collection_name", collection_name)
  return window[inspector_name]

Template.db_view.helpers
  collections: -> Session.get("collections")


Meteor.Router.add
  '/data': ->
    Session.set "collections", Collections.find().fetch()
    return 'db_view'

  '/data/:collection': (collection_name) ->
    collection = setup_collection collection_name
    return 'collection_view'

  '/data/:collection/:document': (collection_name, document_id) ->
    collection = setup_collection collection_name
    Session.set('document_id', document_id)
    return 'document_view'

window.get_fields = (documents) ->
  key_to_type = {_id: 'ObjectId'}
  find_fields = (document, prefix='') ->
    for key, value of _.omit(document, '_id')
      if typeof value is 'object'
        # find_fields value, "#{prefix}#{key}."
      else if typeof value isnt 'function'
        full_path_key = "#{prefix}#{key}"
        key_to_type[full_path_key] = typeof value

  for document in documents
    find_fields document

  (name: key, type: value for key, value of key_to_type)

window.lookup = (object, path) ->
  console.log "looking up #{object} . #{path}"
  return '' unless object?
  return object._id._str if path =='_id'and typeof object._id == 'object'
  result = object
  for part in path.split(".")
    result = result[part]
    return '' unless result?  # quit if you can't find anything here
  if typeof result isnt 'object' then result else ''
