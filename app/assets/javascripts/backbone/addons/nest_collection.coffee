# from: https://gist.github.com/1610397 in the comments
Backbone.Model::nestCollection = (attributeName, collectionClass, nestedCollection) ->
  # don't instantiate if it's already a collection
  if nestedCollection not instanceof collectionClass
    nestedCollection = new collectionClass nestedCollection

  # reset the array
  @set attributeName, []

  #setup nested references
  for item, i in nestedCollection
    @attributes[attributeName][i] = nestedCollection.at(i).attributes

  #create empty arrays if none
  nestedCollection.bind 'add', (initiative) =>
    if !@get(attributeName)
      @attributes[attributeName] = []
    @get(attributeName).push(initiative.attributes)

  nestedCollection.bind 'remove', (initiative) =>
    updateObj = {}
    updateObj[attributeName] = _.without(@get(attributeName), initiative.attributes)
    @set(updateObj)

  nestedCollection
