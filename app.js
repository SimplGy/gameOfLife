/*globals console, $, Backbone, _, Mustache, TodoCollection, TodoView, Dropbox, CellModel, CellView */
/*jshint asi:true, laxcomma:true */


;(function(window, undefined, $){
    var Application, _defaultMetabolism = 100

    Application = Backbone.View.extend({
        events:  {
            'touchstart': 'startPress',
            'mousedown': 'startPress',
            'mouseup': 'endPress',
            'touchend': 'endPress'
        },
        startPress: function() { this.isPressing = true },
        endPress: function() { this.isPressing = false },
        initialize: function(columns, rows, size) {
            _.bindAll(this)
            this.columns = columns
            this.rows = rows
            this.cellSize = size
            this.paused = true
            this.setElement('#GameOfLife')
            this.buildCells()
            this.render()
            $('#Start').on('click', this.toggleBtnClicked)
            $('#Clear').on('click', this.cleanSlate)
            $('#Random').on('click', this.randomize)
        },

        buildCells: function () {
            //console.log("Building a grid with " + this.columns + " columns and "+ this.rows +" rows")
            var i, j, curModel, curView, cell2d = []
            this.cells = []

            // Build a new CellModel for every column & row
            for (i=0; i<this.rows; i++) {
                cell2d[i] = []
                for (j=0; j<this.columns; j++) {
                    curModel = new CellModel({ 'x': i, 'y': j, 'size': this.cellSize })
                    curView = new CellView({ model: curModel, app: this })
                    cell2d[i].push( curModel )
                    this.cells.push( curModel )
                    this.$el.append( curView.el )
                }
                this.$el.append('<br/>')
            }

            // Give each cell a reference to all its neighbors
            _.each(this.cells, function(cell){
                cell.calculateNeighbors(cell2d)
            }.bind(this))
        },

        toggleBtnClicked: function () {
            if (this.paused) {
                this.start()
            } else {
                this.stop()
            }
        },

        stop: function () {
            $('body').removeClass('running')
            this.paused = true
            $('#Start').text('Start')
        },
        start: function () {
            $('body').addClass('running')
            this.paused = false
            this.metabolism = $('#Metabolism').val() || _defaultMetabolism
            this.live()
            $('#Start').text('Stop')
        },

        live: function () {
            if (this.paused) { return }

            // Determine what to do in the next step
            _.each( this.cells, function(cell) { cell.compete() })
            // Live out the next step
            _.each( this.cells, function(cell) { cell.step() })
            // Keep on simulating life
            if (!this.paused) {
                setTimeout(this.live, this.metabolism)
            }
        },

        cleanSlate: function () {
            _.each( this.cells, function(cell) { cell.kill() })
            _.each( this.cells, function(cell) { cell.step() })
            this.stop()
        },

        randomize: function () {
            _.each( this.cells, function(cell) { cell.randomize() })
        }

    })

    // Publicize
    window.Application = Application
})(window, undefined, $)



