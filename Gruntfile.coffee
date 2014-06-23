LIVERELOAD_PORT = 35729
lrSnippet = require("connect-livereload")(port: LIVERELOAD_PORT)
mountFolder = (connect, dir) ->
  connect.static require("path").resolve(dir)


# # Globbing
# for performance reasons we're only matching one level down:
# 'test/spec/{,*/}*.js'
# use this if you want to recursively match all subfolders:
# 'test/spec/**/*.js'
module.exports = (grunt) ->

  # show elapsed time at the end
  require("time-grunt") grunt

  # load all grunt tasks
  require("load-grunt-tasks") grunt

  # configurable paths
  yeomanConfig =
    app: ""
    tmp: '.tmp'

  grunt.initConfig
    yeoman: yeomanConfig
    watch:

      styles:
        files: ["<%= yeoman.app %>/styles/{,*/}*.css"]
        tasks: ["copy:styles"]

      livereload:
#        options:
#          livereload: LIVERELOAD_PORT

        files: [
          "<%= yeoman.app %>/*.html"
          "<%= yeoman.app %>/{,*/}{,*/}{,*/}*.css"
          "<%= yeoman.app %>/{,*/}{,*/}{,*/}*.js"
          "<%= yeoman.app %>/images/{,*/}*.{png,jpg,jpeg,gif,webp,svg}"
        ]

    connect:
      options:
        port: 3001
        hostname: "0.0.0.0"

      livereload:
        options:
          keepalive: true
          livereload: LIVERELOAD_PORT
          middleware: (connect) ->
            [
#              lrSnippet
              mountFolder(connect, yeomanConfig.tmp)
              mountFolder(connect, yeomanConfig.app)
            ]


    open:
      server:
        path: "http://localhost:<%= connect.options.port %>"


  # --------------------------------- Server Tasks
  grunt.registerTask "server", [
    "open"
    "connect:livereload"
  ]


  # --------------------------------- Build Tasks


  grunt.registerTask "default", [ "server" ]
