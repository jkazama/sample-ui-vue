root = 
  src:      "./source"
  dist:     "./public"
  # dist:     "../src/main/resources/static"

path =
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
    jade:
      layout: "#{path.src.html}/layout/**/*.jade"
      page:   "#{path.src.html}/page/**/*.jade"
    coffee:
      const:  "#{path.src.js}/constants/**/*.coffee"
      base:   "#{path.src.js}/platform/**/*.coffee"
      page:   "#{path.src.js}/page/**/*.coffee"
    sass:
      base:   "#{path.src.css}/platform/**/*.s+(a|c)ss"
      page:   "#{path.src.css}/page/**/*.s+(a|c)ss"
    static:   "#{path.src.static}/*"
    fonts:    "bower_components/fontawesome/fonts/*"
  dist:
    html:     "#{path.dist.root}/**/*.html"
    css:      "#{path.dist.css}/**/*.css"
    js:       "#{path.dist.js}/**/*.js"

config =
  coffeelint:
    max_line_length: {value: 200}

gulp        = require "gulp"
$           = do require "gulp-load-plugins"

del         = require "del"
pathutil    = require "path"
bower       = require "bower"
bowerFiles  = require "main-bower-files"
browserSync = require("browser-sync").create()

# build and watch for developer
gulp.task "default", ["clean", "build", "server"]

# clean dist
gulp.task "clean", -> del.sync ["#{path.dist.root}/*", "!#{path.dist.root}/.git*"], { dot: true, force: true }

## build all
gulp.task "build", ["bower", "jade-layout", "sass-platform", "sass-page", "coffee-platform", "coffee-page", "static"]

# build Vendor UI Library (bower.json) [Load/Concat]
gulp.task "bower", ->
  bower.commands.install().on "end", ->
    gulp.src(bowerFiles({filter: "**/*.css"}))
      .pipe($.concat("vendor.css"))
      .pipe(gulp.dest(path.dist.css))
    gulp.src(resource.src.fonts) # for font-awesome
      .pipe(gulp.dest(path.dist.fonts))
    filter = (file) ->           # for bootstrap-sass-official
      /.*\.js/.test(file) and $.slash(file).indexOf("/bootstrap/") is -1
    gulp.src(bowerFiles({filter: filter}))
      .pipe($.concat("vendor.js"))
      .pipe(gulp.dest(path.dist.js))

# compile Jade -> HTML
gulp.task "jade-layout", ->
  gulp.src([resource.src.jade.layout, resource.src.jade.page])
    .pipe($.plumber())
    .pipe($.jade())
    .pipe($.htmlhint())
    .pipe($.htmlhint.reporter())
    .pipe(gulp.dest(path.dist.root))
    .pipe(browserSync.stream())  
gulp.task "jade-page", ->
  gulp.src(resource.src.jade.page)
    .pipe($.plumber())
    .pipe($.changed(path.dist.root, {extension: '.html'}))
    .pipe($.jade())
    .pipe($.htmlhint())
    .pipe($.htmlhint.reporter())
    .pipe(gulp.dest(path.dist.root))
    .pipe(browserSync.stream())

# compile Sass -> CSS
# check https://github.com/sasstools/sass-lint/pull/168
gulp.task "sass-platform", ->
  gulp.src(resource.src.sass.base)
    .pipe($.plumber())
    # .pipe($.sassLint())
    # .pipe($.sassLint.format())
    # .pipe($.sassLint.failOnError())
    .pipe($.sass())
    .pipe($.concat("platform.css"))
    .pipe($.pleeease())
    .pipe(gulp.dest(path.dist.css))
    .pipe(browserSync.stream())

gulp.task "sass-page", ->
  gulp.src(resource.src.sass.page)
    .pipe($.plumber())
    .pipe($.changed(path.dist.css, {extension: '.css'}))
    # .pipe($.sassLint())
    # .pipe($.sassLint.format())
    # .pipe($.sassLint.failOnError())
    .pipe($.sass())
    .pipe($.pleeease())
    .pipe(gulp.dest(path.dist.css))
    .pipe(browserSync.stream())

# compile Coffee -> JS
gulp.task "coffee-platform", -> # constants.js / platform.js
  gulp.src(resource.src.coffee.const)
    .pipe($.plumber())
    .pipe($.coffeelint(config.coffeelint))
    .pipe($.coffeelint.reporter())
    .pipe($.coffee())
    .pipe($.order(["**/namespace.js", "**/constants.js", "**/variables.js", "**/*"]))
    .pipe($.concat("constants.js"))
    .pipe(gulp.dest(path.dist.js))
    .pipe(browserSync.stream())
  gulp.src(resource.src.coffee.base)
    .pipe($.plumber())
    .pipe($.coffeelint(config.coffeelint))
    .pipe($.coffeelint.reporter())
    .pipe($.coffee())
    .pipe($.order(["**/plain.js", "**/jquery.js", "**/vue.js", "**/*"]))
    .pipe($.concat("platform.js"))
    .pipe(gulp.dest(path.dist.js))
    .pipe(browserSync.stream())

gulp.task "coffee-page", -> # multiple page
  gulp.src(resource.src.coffee.page)
    .pipe($.plumber())
    .pipe($.changed(path.dist.js, {extension: '.js'}))
    .pipe($.coffeelint(config.coffeelint))
    .pipe($.coffeelint.reporter())
    .pipe($.coffee())
    .pipe(gulp.dest(path.dist.js))
    .pipe(browserSync.stream())

# copy Static Resource
gulp.task "static", ->
  gulp.src(resource.src.static)
    .pipe(gulp.dest(path.dist.root))

# run Development Web Server (BrowserSync) [localhost:3000]
gulp.task "server", ->
  browserSync.init({
    server: {baseDir: path.dist.root}
    notify: false
  })
  # watch for source
  gulp.watch resource.src.bower,         ["bower"]
  gulp.watch resource.src.jade.layout,   ["jade-layout"]
  gulp.watch resource.src.jade.page,     ["jade-page"]
  gulp.watch resource.src.sass.base,     ["sass-platform"]
  gulp.watch resource.src.sass.page,     ["sass-page"]
  gulp.watch resource.src.coffee.const,  ["coffee-platform"]
  gulp.watch resource.src.coffee.base,   ["coffee-platform"]
  gulp.watch resource.src.coffee.page,   ["coffee-page"]
  gulp.watch resource.src.static,        ["static"]
