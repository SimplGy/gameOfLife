gameOfLife
==========

Conway's Game of Life implemented in Backbone.

Each cell on the screen is an autonomous Backbone Model, aware of its neighbors and how it should behave in this environment.



## Planned Features

* No more than N cells wide, if it goes bigger, grow the cell size
* No narrower than M cells narrow, if it goes narrower, shrink the cell size
* Improve draw performance
  * Use absolute positioning instead of floating
  * Get each draw on an isolated layer
  * use rAF
* Improve compute performance
  * Measure current perf
  * Don't recompute the whole grid every time, only neighbors
  * Remove obviously dumb things from the compute loop (like loop twice, once to `compete` and once to `step`)
  * Measure perf again
* Remove Backbone, do in vanilla
* Pause while dragging, resume right after
* Pause should resume after N seconds of **inactivity**, so you aren't rushed when drawing
* Restructure so github pages can deploy it for me
* #fluff: notice when the simulation is "stable", congratulate the user
* #fluff: Try a train-station style circle-flipping animation to change states
* #fluff: For a really nice looking initial state, weight live cells towards the circular center and make it less likely for them to be alive towards the fringes.
* #fluff: Scale the number of cells until a perf limit is hit (eg: keep adding cells until the `live` loop takes ~7ms to compute)

## Completed

* Convert to coffeescript, because why type moar?
* Instead of start/stop, have the simulation always running, but introduce a pause button that sleeps it for N seconds--long enough to draw one of the game of life launchers or other patterns
* Recalculate the sizing every window resize
* Do the metabolism as a "speed" slider so it's less arcane looking
* Remove the randomize button, but have the simulation always start randomized.