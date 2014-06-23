
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
    @model.on "change:isAlive", @onChangeIsAlive
    @render()

  render: ->
    size = @model.get 'size'
    transform = "translate3d(#{size * @model.get 'y'}px, #{size * @model.get 'x'}px, 0)"  # Faster than pos:abs. Like 4ms vs 8ms per step
    @$el.css
      width:  size
      height: size
#      left:   size * @model.get 'y' # the x/y is backwards, but works for the other methods
#      top:    size * @model.get 'x'
      '-webkit-transform': transform
      '-moz-transform': transform

# Change the visual representation of aliveness
  onChangeIsAlive: ->
    if @model.get("isAlive")
      @$el.addClass "alive"
    else
      @$el.removeClass "alive"

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

  kill: -> @willLive = false

  birth: -> @willLive = true

  randomize: ->
    @willLive = null
    @set "isAlive", !(Math.round(Math.random() * 10) % 5) # one in five chance


  # Look at neighbors and determine if I should stay alive, stay dead, be born, or die
  compete: ->
    # Get the count of live neighbors
    count = 0
    for n in @neighbors
      count++ if n.get 'isAlive'

    # If alive
    if @get("isAlive")
      switch count
        when 0, 1   # Any live cell with fewer than two live neighbours dies, as if caused by under-population
          @kill()
        when 2, 3   # Any live cell with two or three live neighbours lives on to the next generation
          @birth()
        else        # Any live cell with more than three live neighbours dies, as if by overcrowding
          @kill()
    else
      if count is 3 # Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction
        @birth()


  # Move to the next step in the simulation
  step: ->
    curr = @get 'isAlive'
    if curr isnt @willLive
      @set "isAlive", @willLive
)

# Publicize
window.CellModel = Model
window.CellView = View
