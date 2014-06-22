
_pauseLength = 5 * 1000
_cellsWide = 75

GameRunner = Backbone.View.extend(
  events:
    touchstart: "startPress"
    mousedown: "startPress"
    mouseup: "endPress"
    touchend: "endPress"

  initialize: ->
    _.bindAll this
    @setElement "#GameOfLife"
    @render()
    $(window).on "resize", _.debounce @render, 100
    # UI Event Bindings
#    $("#Clear").on "click", @cleanSlate
    $("#Metabolism").on "change", @onMetabolismChange

  render: ->
    @stop()
    @buildCells()
    @randomize()
    @start()


  startPress: -> @isPressing = true
  endPress: -> @isPressing = false

  buildCells: ->
    @$el.empty()
    console.log 'buildCells'

    availWidth = window.innerWidth
    availHeight = window.innerHeight
    # What size should each cell be?
    cellSize = availWidth / _cellsWide
    # How many cells wide and tall will fit?
    @cols = Math.floor availWidth / cellSize
    @rows = Math.floor availHeight / cellSize

    j = undefined
    curModel = undefined
    curView = undefined
    cell2d = []
    @cells = []

    # Build a new CellView and CellModel for every column + row
    i = 0
    while i < @rows
      cell2d[i] = []
      j = 0
      while j < @cols
        curModel = new CellModel(
          x: i
          y: j
          size: cellSize
        )
        curView = new CellView(
          model: curModel
          app: this
        )
        cell2d[i].push curModel
        @cells.push curModel
        @$el.append curView.el
        j++
      i++

    # Give each cell a reference to all its neighbors
    _.each @cells, ((cell) ->
      cell.calculateNeighbors cell2d
    ).bind(this)



  # -------------------------------------------- Run Loop
  live: ->
    console.time 'live'
    _.each @cells, (cell) -> cell.compete()         # Determine what to do in the next step
    _.each @cells, (cell) -> cell.step()            # Live out the next step
    setTimeout @live, @metabolism  unless @paused   # Keep on simulating life
    console.timeEnd 'live'



  # -------------------------------------------- User Actions
  stop: ->
    @paused = true

  start: ->
    @paused = false
    @onMetabolismChange()
    @live()

  cleanSlate: ->
    _.each @cells, (cell) -> cell.kill()
    _.each @cells, (cell) -> cell.step()
    @stop()

  randomize: ->
    _.each @cells, (cell) ->
      cell.randomize()

  onMetabolismChange: ->
    speed = $("#Metabolism").val()                # 0-100 scale
    @metabolism = Math.abs(speed - 100) * 2 + 10  # Convert to a frame rate where lower is faster
#    console.log "Metabolism Changed", @metabolism
)

# Publicize
window.GameRunner = GameRunner

