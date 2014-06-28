gameOfLife
==========

[Conway's Game of Life](http://en.wikipedia.org/wiki/Conway_game_of_life) implemented in Backbone. If you haven't heard of it, here's a [sweet video](https://www.youtube.com/watch?v=C2vgICfQawE).

Each cell on the screen is an autonomous Backbone Model, aware of its neighbors and how it should behave in this environment.

[![Animated gif of game in action.](/img/interacting.gif?raw=true)]((http://simpleascouldbe.github.io/gameOfLife/))

## Approach

* Figure out how many rows and cols will fit on the screen
* Create a list of cells. Each cell is a Backbone Model/View pair.
* Each cell knows it's x/y coord
* Each cell calculates references to its 8 neighbors one time
* Every step of the application, cells decide whether they're going to live or die in the next frame
* Then the app tells every cell to advance one frame

This isn't very performant, since there's overhead involved in standing up a self-aware model for each cell,
but it is idiomatic for a Backbone app and results in code with clear separation of responsibility.

I plan to build a vanilla version of this that uses a 2d array for storage and compare the performance.

## Learnings

### Backbone.Model.set

Backbone.Model.set is extremely expensive. It uses extend, and 30% of the compute time in my loop was spent on this. I was just defaulting properties to null, but this was costly.
Using model properties that throw events only for properties where they're really needed resulted in a huge performance gain (in the order of 120ms to 20ms).

### Paint Rectangles

Setting the position of the elements as `absolute` with left and top offsets is not enough to tell the paint system that the elements do not affect each other.
You can see paint rectangles in the timeline, and using top left positioning, the entire screen is redrawn if even one cell changes. This isn't optimal in theory and wasn't optimal when measured.
Instead, positioning each cell with a `translate3d` results in separate paintable rectangles for each cell. The frames view of timeline shows all the individual timeline paint events and the composite layer event.
It was faster for this application to paint many (many!) rectangles and composite them than to paint the whole screen every frame.


## Planned Features

* #bug: click and hold, drag. click again, delay correctly extends. click and drag again, delay doesn't hold. clearTimeout is only happening on mouseup.
* #demo: take animated gif of pos:abs version and translate version showing the difference in the paint rectangles. It looks cool and illustrates a good point.
* display indication when paused and countdown to resume so the behavior is clear
* Build with vanilla JS to model and canvas or d3 to draw
* #fluff: gameify the clearing of the board, congratulate the player
* #fluff: For a really nice looking initial state, weight live cells towards the circular center and make it less likely for them to be alive towards the fringes.
* #fluff: Scale the number of cells until a perf limit is hit (eg: keep adding cells until the `live` loop takes ~7ms to compute)
* #fluff: Try a train-station style circle-flipping animation to change states -- tried. couldn't get it to transition the rotateY transform, even though I've done it with animations in the past.


## Completed

* Restructure so github pages can deploy it for me
* Pause while dragging, resume after. Long press pauses so you can click around for a bit
* Always show N cells at the most (wide or tall).
* Determine performance bottleneck -- the setting of classes in css is 10% or more of the work. Setting style attribute directly is almost as slow.
* Convert to coffeescript, because why type moar?
* Instead of start/stop, have the simulation always running, but introduce a pause button that sleeps it for N seconds--long enough to draw one of the game of life launchers or other patterns
* Recalculate the sizing every window resize
* Do the metabolism as a "speed" slider so it's less arcane looking
* Remove the randomize button, but have the simulation always start randomized.
* use rAF
* Measure current perf -- avg run time for the `live` loop of a 50x50 grid is about 120-90ms. as low as 50ms if there are few live cells.
* measure -- border radius on each cell makes a **significant** difference in paint performance. 66% slower or so
* measure -- most time is in compute. live step: 33ms. paint: 10ms.
* Use absolute positioning instead of floating
* Make sure it's not calling render even when there's no change to the model (setting false over the top of false, for example)
* doing many backbone model `set`s is expensive. 30% of compute time was spend doing `_.extend`, which is part of `.set`
* Scale the number of cells until the frame rate is good enough -- tried, took too long to calculate and interrupted the animation when reset.
* #perf: Take advantage of this: A cell that did not change at the last time step, and none of whose neighbours changed, is guaranteed not to change at the current time step as well.
  * Meh. The issue is dom manipulation time, not algo time.
