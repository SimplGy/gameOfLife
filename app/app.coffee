
Application = undefined
_defaultMetabolism = 100
_pauseLength = 3 * 1000
Application = Backbone.View.extend(
  events:
    touchstart: "startPress"
    mousedown: "startPress"
    mouseup: "endPress"
    touchend: "endPress"

  startPress: ->
    @isPressing = true

  endPress: ->
    @isPressing = false

  initialize: (columns, rows, size) ->
    _.bindAll this
    @columns = columns
    @rows = rows
    @cellSize = size
    @setElement "#GameOfLife"
    @buildCells()
    @render()
    @randomize()
    @live()
    $("#Pause").on "click", @onPauseBtnClick
    $("#Clear").on "click", @cleanSlate
    $("#Random").on "click", @randomize

  buildCells: ->

    #console.log("Building a grid with " + this.columns + " columns and "+ this.rows +" rows")
    i = undefined
    j = undefined
    curModel = undefined
    curView = undefined
    cell2d = []
    @cells = []

    # Build a new CellModel for every column & row
    i = 0
    while i < @rows
      cell2d[i] = []
      j = 0
      while j < @columns
        curModel = new CellModel(
          x: i
          y: j
          size: @cellSize
        )
        curView = new CellView(
          model: curModel
          app: this
        )
        cell2d[i].push curModel
        @cells.push curModel
        @$el.append curView.el
        j++
      @$el.append "<br/>"
      i++

    # Give each cell a reference to all its neighbors
    _.each @cells, ((cell) ->
      cell.calculateNeighbors cell2d
    ).bind(this)

  onPauseBtnClick: ->
#    return if @paused
    $("#Pause").attr 'disabled', true
    @stop()
    setTimeout =>
      $("#Pause").removeAttr 'disabled'
      @start()
    , _pauseLength




  stop: ->
    $("body").removeClass "running"
    @paused = true
    $("#Start").text "Start"

  start: ->
    $("body").addClass "running"
    @paused = false
    @metabolism = $("#Metabolism").val() or _defaultMetabolism
    @live()
    $("#Start").text "Stop"

  live: ->
    _.each @cells, (cell) -> cell.compete()         # Determine what to do in the next step
    _.each @cells, (cell) -> cell.step()            # Live out the next step
    setTimeout @live, @metabolism  unless @paused   # Keep on simulating life

  cleanSlate: ->
    _.each @cells, (cell) -> cell.kill()
    _.each @cells, (cell) -> cell.step()
    @stop()

  randomize: ->
    _.each @cells, (cell) ->
      cell.randomize()
)

# Publicize
window.Application = Application

