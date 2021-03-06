Template.document_view.helpers
  collection_name: -> Session.get('collection_name')
  adminHide: -> if Session.get('admin_should_show') then '' else 'hide'
  items: ->
    order = Order.findOne _id: Session.get('document_id')
    if order then order.items
  fields: ->
    document = get_collection().findOne _id: Session.get('document_id')
    unless document
      try
        document = get_collection().findOne _id: new Meteor.Collection.ObjectID(Session.get('document_id'))
      catch error
        console.log error
    fields = get_fields([document])
    console.log fields
    #To make document not go away
    console.log document
    l = (field_name: field.name, field_value: lookup(document, field.name) for field in fields)
    console.log l
    l
  field_is_id: -> @field_name is '_id'
  document_id: -> Session.get('document_id')

get_collection = -> window["inspector_#{Session.get('collection_name')}"]

Template.document_view.events
  'click .admin-save': (e) ->
    e.preventDefault()
    old_object = get_collection().findOne _id: Session.get('document_id')
    unless old_object
      try
        old_object = get_collection().findOne _id: new Meteor.Collection.ObjectID(Session.get('document_id'))
      catch error
        console.log error
    update_dict = {}
    for field in $('.field')
      unless field.name is '_id'
        update_dict[field.name] = if typeof(old_object[field.name]) == 'number'
            parseFloat(field.value)
          else if typeof(old_object[field.name]) == 'boolean'
            (field.value == 'true')
    Meteor.call("admin_#{Session.get('collection_name')}_update",
      Session.get('document_id'), $set: update_dict)
    Session.set('admin_should_show', true)
    setTimeout (->
      Session.set('admin_should_show', false)
    ), 1500

  'click .admin-delete': (e) ->
    e.preventDefault()
    Meteor.call "admin_#{Session.get('collection_name')}_delete",
      Session.get('document_id')
    Meteor.Router.to "/data/#{Session.get('collection_name')}"
  "click a.home": (e) ->
    Meteor.Router.to("/data/")
  "click a.collection": (e) ->
    Meteor.Router.to("/data/#{Session.get('collection_name')}")
