gameOfLife
==========

[Conway's Game of Life](http://en.wikipedia.org/wiki/Conway_game_of_life) implemented in Backbone.

Each cell on the screen is an autonomous Backbone Model, aware of its neighbors and how it should behave in this environment.

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

Backbone.Model.set is extremely expensive. It uses extend, and 30% of the compute time in my loop was spend on this.
Using model properties that throw events only for properties where they're really needed resulted in a huge performance gain (120ms to 20ms).


## Planned Features

* use rAF?
* No more than N cells wide, if it goes bigger, grow the cell size
* No narrower than M cells narrow, if it goes narrower, shrink the cell size
* #perf: Don't recompute the whole grid every time, only neighbors
* Remove Backbone, do in vanilla
* Pause while dragging, resume right after
* Pause should resume after N seconds of **inactivity**, so you aren't rushed when drawing
* Restructure so github pages can deploy it for me
* #fluff: notice when the simulation is "stable", congratulate the user
* #fluff: Try a train-station style circle-flipping animation to change states
* #fluff: For a really nice looking initial state, weight live cells towards the circular center and make it less likely for them to be alive towards the fringes.
* #fluff: Scale the number of cells until a perf limit is hit (eg: keep adding cells until the `live` loop takes ~7ms to compute)
* #demo: take animated gif of pos:abs version and translate version showing the difference in the paint rectangles. It looks cool and illustrates a good point.


## Completed


* Convert to coffeescript, because why type moar?
* Instead of start/stop, have the simulation always running, but introduce a pause button that sleeps it for N seconds--long enough to draw one of the game of life launchers or other patterns
* Recalculate the sizing every window resize
* Do the metabolism as a "speed" slider so it's less arcane looking
* Remove the randomize button, but have the simulation always start randomized.

* Measure current perf -- avg run time for the `live` loop of a 50x50 grid is about 120-90ms. as low as 50ms if there are few live cells.
* measure -- border radius on each cell makes a **significant** difference in paint performance. 66% slower or so
* measure -- most time is in compute. live step: 33ms. paint: 10ms.
* Use absolute positioning instead of floating
* Make sure it's not calling render even when there's no change to the model (setting false over the top of false, for example)
* doing many backbone model `set`s is expensive. 30% of compute time was spend doing `_.extend`, which is part of `.set`