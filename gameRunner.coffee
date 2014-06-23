
_pauseLength = 2 * 1000
_cellLimit = 60 # How many cells should we draw, limited by the longest side? This number is the key performance pusher.
_tooSlow = 30


GameRunner = Backbone.View.extend(
  events:
    touchstart: "startPress"
    mousedown: "startPress"
    mouseup: "endPress"
    touchend: "endPress"

  initialize: ->
    _.bindAll this
    @setElement "#GameOfLife"
    @cellLimit = _cellLimit
    @styleNode = document.createElement 'style'
    @styleNode.type = 'text/css'
    document.head.appendChild @styleNode
    @render()
    $(window).on "resize", _.debounce =>
      @cellLimit = _cellLimit
      @render()
    , 100
    # UI Event Bindings
#    $("#Clear").on "click", @cleanSlate
    $("#Metabolism").on "change", @onMetabolismChange

  render: ->
    @stop()
    @buildCells()
    @randomize()
    @start()

  startPress: ->
    @paused = true
    @isPressing = true
    @pressTime = Date.now()
  endPress:   ->
    if Date.now() - @pressTime > _pauseLength/2
      @longPress = true
    # If there's a long press, pause for a while to let the person interact with the simulation in more detail.
    if @longPress
      clearTimeout @timer
      @timer = setTimeout =>
        @paused = false
        @longPress = false
      ,
        _pauseLength
    else
      @paused = false
    @isPressing = false

  buildCells: ->
    @$el.empty()
    console.log 'buildCells'

    # What size should each cell be?
    cellSize = Math.max(window.innerWidth, window.innerHeight) / @cellLimit
    # How many cells wide and tall will fit?
    @cols = Math.floor window.innerWidth / cellSize
    @rows = Math.floor window.innerHeight / cellSize
    # Set the css size of the cells
    @setStylesheetRule ".gameOfLife i { width: #{cellSize}px; height: #{cellSize}px; }"

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
  # Calls as often as the browser is able to render
  animationTick: ->
    # Measure the frame rate, lower cell count until an acceptable frame rate is found
    # This worked ok, but it took 5-20 seconds to figure out a good cell count, so it wasn't good enough.
#    @frames = @frames || []
#    @frames.push Date.now() - @lastFrame || 0
#    if @frames.length >= 10
#      # The average of the last 50% of the frames (the first couple frames are always slow)
#      sum = _.reduce @frames.slice(-(@frames.length * .5)),
#        (memo, n) -> memo + n
#      avg = sum / @frames.length
#      @frames = []
#      if avg > _tooSlow
#        console.log "Frame Rate: #{avg}"
#        console.warn 'Warning, too slow. Taking responsibilities away!'
#        reduction = if avg - _tooSlow > 100 then 10 else 2 # Reduce by a lot if we're far away from stutter-free
#        @cellsWide -= reduction
#        @render()
#      else
#        console.debug "#{@cellsWide} cells draw ok"


    @lastFrame = Date.now()
    # Should we move the simulation forward a step?
    stepDiff = Date.now() - @lastStep
    @live() unless @metabolism > stepDiff # this flip of logic lets it handle NaN (initial) as a "should-render" case
    # Always request the next animation frame
    window.requestAnimationFrame @animationTick

  # Called whenever the simulation is supposed to take a step forward
  live: ->
    return if @paused
#    console.log "#{Date.now() - @lastStep} >= #{@metabolism}"
    @lastStep = Date.now()
#    console.time 'computeCells'
    _.each @cells, (cell) -> cell.compete()         # Determine what to do in the next step
    _.each @cells, (cell) -> cell.step()            # Live out the next step
#    console.timeEnd 'computeCells'
#    setTimeout @live, @metabolism  unless @paused   # Keep on simulating life





  # -------------------------------------------- User Actions
  stop: ->
    @paused = true

  start: ->
    @paused = false
    @onMetabolismChange()
    @animationTick()

  cleanSlate: ->
    _.each @cells, (cell) -> cell.kill()
    _.each @cells, (cell) -> cell.step()
    @stop()

  randomize: ->
    _.each @cells, (cell) ->
      cell.randomize()

  onMetabolismChange: ->
    speed = $("#Metabolism").val()                # 0-100 scale
    @metabolism = Math.abs(speed - 100) * 1.5 + 10  # Convert to a frame rate where lower is faster
#    console.log "Metabolism Changed", @metabolism


  # -------------------------------------------- Helpers
  setStylesheetRule: (rule) ->
    @styleNode.innerHTML = ''
    if @styleNode.stylesheet
      @styleNode.styleSheet.cssText = rule
    else
      @styleNode.appendChild document.createTextNode rule
)

# Publicize
window.GameRunner = GameRunner

