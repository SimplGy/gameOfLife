/*globals console, $, Backbone, _, Mustache, TodoCollection, TodoView, Dropbox */
/*jshint asi:true, laxcomma:true */


;(function(window){
    var Model, View

    View = Backbone.View.extend({
        tagName: 'i',
        events: {
            'touchstart': 'cellClicked',
            'mousedown': 'cellClicked',
            'mouseover': 'mouseover',
            'mouseout': 'mouseout',
            'touchend': 'mouseout'
        },
        initialize: function () {
            _.bindAll(this)
            this.model.on('change:isAlive', this.render)
            //var sz = this.model.get('size')
            //this.$el.attr('style', 'top:'+ sz*this.model.get('y') +'px;left:'+ sz*this.model.get('x') +'px;')
            this.render(this.model)
        },
        render : function (model) {
            // Change the visual representation of aliveness
            if (model.get('isAlive')) {
                this.$el.addClass('alive')
            } else {
                this.$el.removeAttr('class')
            }
        },
        mouseover: function () {
            if(this.options.app.isPressing && !this.alreadyToggled) {
                this.model.toggle()
                this.alreadyToggled = true
            }
        },
        mouseout: function () {
            this.alreadyToggled = false
        },
        cellClicked: function () {
            this.model.toggle()
        }
    })

    Model = Backbone.Model.extend({
        defaults: {
            isAlive: false,
            willLive: null,
            x: null,
            y: null,
            size: null
        },
        initialize: function () {
            this.neighbors = [] //Yes, I know this isn't a model property. The push syntax is too cumbersome and I don't need the eventing on neighbors
        },
        /**
         * Given a grid of items, determine which items are adjacent to me.
         * Requires that this.x and this.y be set
         * @param grid a 2d array of models like this one
         */
        calculateNeighbors: function (grid) {
            var x = this.get('x'),
                y = this.get('y')

            //above
            this.setNeighbor(grid, x-1, y-1)
            this.setNeighbor(grid, x, y-1)
            this.setNeighbor(grid, x+1, y-1)
            //same level
            this.setNeighbor(grid, x-1, y)
            this.setNeighbor(grid, x+1, y)
            //below
            this.setNeighbor(grid, x-1, y+1)
            this.setNeighbor(grid, x, y+1)
            this.setNeighbor(grid, x+1, y+1)

            //console.log('['+ this.get('x') +']['+ this.get('y') +'] has '+ this.neighbors.length +' neighbors')
        },
        setNeighbor: function (grid, x, y) {
            if (!grid[x]) { return }
            var possibleNeighbor = grid[x][y]
            if (possibleNeighbor && possibleNeighbor instanceof Backbone.Model) {
                this.neighbors.push( possibleNeighbor )
            }
        },

        toggle: function () {
            this.set(
                'isAlive',
                !this.get('isAlive')
            )
        },
        kill: function () { this.set('willLive', false) },
        birth: function () { this.set('willLive', true) },
        randomize: function () {
            this.set('willLive', null)
            this.set('isAlive', !!(Math.round(Math.random() * 10) % 2) )
        },

        /**
         * Look at neighbors and determine if I should stay alive, stay dead, be born, or die
         */
        compete: function () {
            // Get the count of live neighbors
            var i, count = 0

            for (i=0; i < this.neighbors.length; i++) {
                if (this.neighbors[i].get('isAlive')) {
                    count++
                }
            }

            // If alive
            if (this.get('isAlive')) {
                switch (count) {
                    //Any live cell with fewer than two live neighbours dies, as if caused by under-population
                    case 0:
                    case 1:
                        this.kill()
                        break
                    //Any live cell with two or three live neighbours lives on to the next generation
                    case 2:
                    case 3:
                        this.set('willLive', this.get('isAlive'))
                        break //stays alive
                    //Any live cell with more than three live neighbours dies, as if by overcrowding
                    case 4:
                    case 5:
                    case 6:
                    case 7:
                    case 8:
                        this.kill()
                }

            // If dead
            } else {
                //Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction
                if (count === 3) {
                    this.birth()
                }
            }
        },

        step: function() {
            this.set('isAlive', this.get('willLive'))
            this.set('willLive', null)
        }
    })
    // Publicize
    window.CellModel = Model
    window.CellView = View
})(window)



