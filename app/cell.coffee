
View = Backbone.View.extend(
  tagName: "i"
  events:
    touchstart: "cellClicked"
    mousedown: "cellClicked"
    mouseover: "mouseover"
    mouseout: "mouseout"
    touchend: "mouseout"

  initialize: ->
    _.bindAll this
    @model.on "change:isAlive", @render
    @render @model

  render: (model) ->

    # Change the visual representation of aliveness
    if model.get("isAlive")
      @$el.addClass "alive"
    else
      @$el.removeAttr "class"

  mouseover: ->
    if @options.app.isPressing and not @alreadyToggled
      @model.toggle()
      @alreadyToggled = true

  mouseout: ->
    @alreadyToggled = false

  cellClicked: ->
    @model.toggle()
)







Model = Backbone.Model.extend(
  defaults:
    isAlive: false
    willLive: null
    x: null
    y: null
    size: null

  initialize: ->
    @neighbors = [] # Not a mistake, I know this isn't a model property. The push syntax is too cumbersome and I don't need the eventing on neighbors


  # Given a grid of items, determine which items are adjacent to me.
  # Requires that this.x and this.y be set
  # @param grid a 2d array of models like this one
  calculateNeighbors: (grid) ->
    x = @get("x")
    y = @get("y")

    #above
    @setNeighbor grid, x - 1, y - 1
    @setNeighbor grid, x, y - 1
    @setNeighbor grid, x + 1, y - 1

    #same level
    @setNeighbor grid, x - 1, y
    @setNeighbor grid, x + 1, y

    #below
    @setNeighbor grid, x - 1, y + 1
    @setNeighbor grid, x, y + 1
    @setNeighbor grid, x + 1, y + 1


  setNeighbor: (grid, x, y) ->
    return  unless grid[x]
    possibleNeighbor = grid[x][y]
    @neighbors.push possibleNeighbor  if possibleNeighbor and possibleNeighbor instanceof Backbone.Model

  toggle: ->
    @set "isAlive", not @get("isAlive")

  kill: ->
    @set "willLive", false

  birth: ->
    @set "willLive", true

  randomize: ->
    @set "willLive", null
    @set "isAlive", !!(Math.round(Math.random() * 10) % 2)


  # Look at neighbors and determine if I should stay alive, stay dead, be born, or die
  compete: ->

    # Get the count of live neighbors
    i = undefined
    count = 0
    i = 0
    while i < @neighbors.length
      count++  if @neighbors[i].get("isAlive")
      i++

    # If alive
    if @get("isAlive")
      switch count

      #Any live cell with fewer than two live neighbours dies, as if caused by under-population
        when 0, 1
          @kill()
      #Any live cell with two or three live neighbours lives on to the next generation
        when 2, 3
          @set "willLive", @get("isAlive")
      #stays alive
      #Any live cell with more than three live neighbours dies, as if by overcrowding
        when 4, 5, 6, 7, 8
          @kill()

      # If dead
    else

      #Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction
      @birth()  if count is 3

  step: ->
    @set "isAlive", @get("willLive")
    @set "willLive", null
)

# Publicize
window.CellModel = Model
window.CellView = View
