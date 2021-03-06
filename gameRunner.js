// Generated by CoffeeScript 1.7.1
(function() {
  var GameRunner, _cellLimit, _pauseLength, _tooSlow;

  _pauseLength = 2 * 1000;

  _cellLimit = 60;

  _tooSlow = 30;

  GameRunner = Backbone.View.extend({
    events: {
      touchstart: "startPress",
      mousedown: "startPress",
      mouseup: "endPress",
      touchend: "endPress"
    },
    initialize: function() {
      _.bindAll(this);
      this.setElement("#GameOfLife");
      this.cellLimit = _cellLimit;
      this.styleNode = document.createElement('style');
      this.styleNode.type = 'text/css';
      document.head.appendChild(this.styleNode);
      this.render();
      $(window).on("resize", _.debounce((function(_this) {
        return function() {
          _this.cellLimit = _cellLimit;
          return _this.render();
        };
      })(this), 100));
      return $("#Metabolism").on("change", this.onMetabolismChange);
    },
    render: function() {
      this.stop();
      this.buildCells();
      this.randomize();
      return this.start();
    },
    startPress: function() {
      this.paused = true;
      this.isPressing = true;
      return this.pressTime = Date.now();
    },
    endPress: function() {
      if (Date.now() - this.pressTime > _pauseLength / 2) {
        this.longPress = true;
      }
      if (this.longPress) {
        clearTimeout(this.timer);
        this.timer = setTimeout((function(_this) {
          return function() {
            _this.paused = false;
            return _this.longPress = false;
          };
        })(this), _pauseLength);
      } else {
        this.paused = false;
      }
      return this.isPressing = false;
    },
    buildCells: function() {
      var cell2d, cellSize, curModel, curView, i, j;
      this.$el.empty();
      console.log('buildCells');
      cellSize = Math.max(window.innerWidth, window.innerHeight) / this.cellLimit;
      this.cols = Math.floor(window.innerWidth / cellSize);
      this.rows = Math.floor(window.innerHeight / cellSize);
      this.setStylesheetRule(".gameOfLife i { width: " + cellSize + "px; height: " + cellSize + "px; }");
      j = void 0;
      curModel = void 0;
      curView = void 0;
      cell2d = [];
      this.cells = [];
      i = 0;
      while (i < this.rows) {
        cell2d[i] = [];
        j = 0;
        while (j < this.cols) {
          curModel = new CellModel({
            x: i,
            y: j,
            size: cellSize
          });
          curView = new CellView({
            model: curModel,
            app: this
          });
          cell2d[i].push(curModel);
          this.cells.push(curModel);
          this.$el.append(curView.el);
          j++;
        }
        i++;
      }
      return _.each(this.cells, (function(cell) {
        return cell.calculateNeighbors(cell2d);
      }).bind(this));
    },
    animationTick: function() {
      var stepDiff;
      this.lastFrame = Date.now();
      stepDiff = Date.now() - this.lastStep;
      if (!(this.metabolism > stepDiff)) {
        this.live();
      }
      return window.requestAnimationFrame(this.animationTick);
    },
    live: function() {
      if (this.paused) {
        return;
      }
      this.lastStep = Date.now();
      _.each(this.cells, function(cell) {
        return cell.compete();
      });
      return _.each(this.cells, function(cell) {
        return cell.step();
      });
    },
    stop: function() {
      return this.paused = true;
    },
    start: function() {
      this.paused = false;
      this.onMetabolismChange();
      return this.animationTick();
    },
    cleanSlate: function() {
      _.each(this.cells, function(cell) {
        return cell.kill();
      });
      _.each(this.cells, function(cell) {
        return cell.step();
      });
      return this.stop();
    },
    randomize: function() {
      return _.each(this.cells, function(cell) {
        return cell.randomize();
      });
    },
    onMetabolismChange: function() {
      var speed;
      speed = $("#Metabolism").val();
      return this.metabolism = Math.abs(speed - 100) * 1.5 + 10;
    },
    setStylesheetRule: function(rule) {
      this.styleNode.innerHTML = '';
      if (this.styleNode.stylesheet) {
        return this.styleNode.styleSheet.cssText = rule;
      } else {
        return this.styleNode.appendChild(document.createTextNode(rule));
      }
    }
  });

  window.GameRunner = GameRunner;

}).call(this);
