root = 
  src:      "#{__dirname}/source"
  dist:     "#{__dirname}/public"
  # dist:     "#{__dirname}/src/main/resources/static"
paths =
  src:
    root:     "#{root.src}"
    html:     "#{root.src}/html"
    js:       "#{root.src}/js"
    css:      "#{root.src}/css"
    static:   "#{root.src}/static"
  dist:
    root:     "#{root.dist}"
    js:       "#{root.dist}/js"
    css:      "#{root.dist}/css"
    fonts:    "#{root.dist}/fonts"
  bower:      "bower.json"
resource =
  src:
    jade:     "#{paths.src.html}/**/*.jade"
    webpack:
      coffee: "#{paths.src.js}/**/*.coffee"
      vue:    "#{paths.src.js}/**/*.vue"
    sass:     "#{paths.src.css}/**/*.s+(a|c)ss"
    static:   "#{paths.src.static}/**/*"
    fonts:    "bower_components/fontawesome/fonts/**/*"

gulp   = require "gulp"
$      = do require "gulp-load-plugins"
del    = require "del"
path   = require "path"

bower         = require "bower"
bowerFiles    = require "main-bower-files"
webpack       = require 'webpack'
webpackStream = require "webpack-stream"
vue           = require 'vue-loader'
browserSync   = require("browser-sync").create()

# build and watch for developer
gulp.task "default", ["build", "server"]

## build all
gulp.task "build", ["clean", "bower", "build:jade", "build:sass", "build:webpack", "build:static"]

# clean dist
gulp.task "clean", -> del.sync ["#{paths.dist.root}/*", "!#{paths.dist.root}/.git*"], { dot: true, force: true }

# build Vendor UI Library (bower.json) [Load/Concat]
gulp.task "bower", ->
  bower.commands.install().on "end", ->
    gulp.src(bowerFiles({filter: "**/*.css"}))
      .pipe($.concat("vendor.css"))
      .pipe(gulp.dest(paths.dist.css))
    gulp.src(resource.src.fonts) # for font-awesome
      .pipe(gulp.dest(paths.dist.fonts))
    filter = (file) ->           # for bootstrap-sass-official
      /.*\.js/.test(file) and $.slash(file).indexOf("/bootstrap/") is -1
    gulp.src(bowerFiles({filter: filter}))
      .pipe($.concat("vendor.js"))
      .pipe(gulp.dest(paths.dist.js))

# compile Webpack [ Coffee / Vue -> SPA(main.js) ]
gulp.task "build:webpack", ->
  gulp.src([resource.src.webpack.coffee, resource.src.webpack.vue])
    .pipe(webpackStream({
      entry: "#{paths.src.js}/main.coffee"
      output: {filename: "main.js"}
      module:
        loaders: [
          {test: /\.coffee$/, loader: "coffee"}
          {test: /\.vue$/, loader: vue.withLoaders({sass: "style!css!sass?indentedSyntax"})}
        ]
      resolve:
        moduleDirectories: ["node_modules", "bower_components"]
      plugins:[
        new webpack.ResolverPlugin(new webpack.ResolverPlugin.DirectoryDescriptionFilePlugin("bower.json", ["main"]))
      ]
     }, webpack))
    .pipe(gulp.dest(paths.dist.js))
    .pipe(browserSync.stream())  

# compile Jade -> HTML
gulp.task "build:jade", ->
  gulp.src(resource.src.jade)
    .pipe($.plumber())
    .pipe($.jade())
    .pipe($.htmlhint())
    .pipe($.htmlhint.reporter())
    .pipe(gulp.dest(paths.dist.root))
    .pipe(browserSync.stream())  

# compile Sass -> CSS
# check https://github.com/sasstools/sass-lint/pull/168
gulp.task "build:sass", ->
  gulp.src(resource.src.sass)
    .pipe($.plumber())
    # .pipe($.sassLint())
    # .pipe($.sassLint.format())
    # .pipe($.sassLint.failOnError())
    .pipe($.sass())
    .pipe($.concat("style.css"))
    .pipe($.pleeease())
    .pipe(gulp.dest(paths.dist.css))
    .pipe(browserSync.stream())

# copy Static Resource
gulp.task "build:static", ->
  gulp.src(resource.src.static)
    .pipe(gulp.dest(paths.dist.root))

# run Development Web Server (BrowserSync) [localhost:3000]
gulp.task "server", ->
  browserSync.init({
    server: {baseDir: paths.dist.root}
    notify: false
  })
  # watch for source
  gulp.watch resource.src.bower,           ["bower"]
  gulp.watch resource.src.webpack.coffee,  ["build:webpack"]
  gulp.watch resource.src.webpack.vue,     ["build:webpack"]
  gulp.watch resource.src.jade,            ["build:jade"]
  gulp.watch resource.src.sass,            ["build:sass"]
  gulp.watch resource.src.static,          ["build:static"]

