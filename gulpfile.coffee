root = 
  src:      "./source"
  dist:     "./public"
  # dist:     "../src/main/resources/static"

path =
  src:
    root:   "#{root.src}"
    js:     "#{root.src}/js"
    css:    "#{root.src}/css"
  dist:
    root:   "#{root.dist}"
    js:     "#{root.dist}/js"
    css:    "#{root.dist}/css"
    fonts:  "#{root.dist}/fonts"
  bower:    "bower.json"
resource =
  src:
    jade:   "#{path.src.root}/**/*.jade"
    coffee: "#{path.src.js}/**/*.coffee"
    sass:   "#{path.src.css}/**/*.sass"
    scss:   "#{path.src.css}/**/*.scss"
    static: "#{path.src.root}/static/*"
    fonts:  "bower_components/fontawesome/fonts/*"
  dist:
    html:   "#{path.dist.root}/**/*.html"
    css:    "#{path.dist.css}/**/*.css"
    js:     "#{path.dist.js}/**/*.js"

gulp       = require "gulp"
del        = require "del"
bower      = require 'bower'
bowerFiles = require "main-bower-files"
gulpif     = require "gulp-if"
concat     = require "gulp-concat"
plumber    = require "gulp-plumber"
coffee     = require "gulp-coffee"
jade       = require "gulp-jade"
sass       = require "gulp-sass"
pleeease   = require "gulp-pleeease"
uglify     = require "gulp-uglify"
webserver  = require "gulp-webserver"

# build and watch
gulp.task "default", ["clean", "build", "watch"]

# clean dist
gulp.task "clean", -> del.sync ["#{path.dist.root}/*", "!#{path.dist.root}/.git*"], { dot: true, force: true }

## build all
gulp.task "build", ["bower", "jade", "sass", "coffee", "static"]

## watch Alt Resources
gulp.task "watch", ->
  gulp.watch resource.src.bower,  ["bower"]
  gulp.watch resource.src.jade,   ["jade"]
  gulp.watch resource.src.sass,   ["sass"]
  gulp.watch resource.src.scss,   ["sass"]
  gulp.watch resource.src.coffee, ["coffee"]
  gulp.watch resource.src.static, ["static"]

# build Vendor Library [Load/Concat]
gulp.task "bower", ->
  bower.commands.install().on "end", ->
    gulp.src(bowerFiles({filter: "**/*.css"}))
      .pipe(concat("lib.css"))
      .pipe(gulp.dest(path.dist.css))
    gulp.src(resource.src.fonts) # for font-awesome
      .pipe(gulp.dest(path.dist.fonts))
    gulp.src(bowerFiles({filter: "**/*.js"}))
      .pipe(concat("lib.js"))
      .pipe(gulp.dest(path.dist.js))

# compile Jade -> HTML
gulp.task "jade", ->
  gulp.src(resource.src.jade)
    .pipe(plumber())
    .pipe(jade())
    .pipe(gulp.dest(path.dist.root))

# compile Sass -> CSS
gulp.task "sass", ->
  gulp.src([resource.src.sass, resource.src.scss])
    .pipe(plumber())
    .pipe(sass())
    .pipe(pleeease())
    .pipe(gulp.dest(path.dist.css))

# compile Coffee -> JavaScript
gulp.task "coffee", ->
  gulp.src(resource.src.coffee)
    .pipe(plumber())
    .pipe(coffee())
    .pipe(uglify())
    .pipe(gulp.dest(path.dist.js))

# copy Static Resource
gulp.task "static", ->
  gulp.src(resource.src.static)
    .pipe(gulp.dest(path.dist.root))

# run Web Server (BrowserSync) [localhost:4567]
gulp.task "server", ->
  browserSync = require("browser-sync").create()
  browserSync.init({
    port: 4567
    server: {baseDir: path.dist.root}
    ui: {port: 4569}
    notify: false
  })
  gulp.watch(resource.dist.html).on("change", browserSync.reload)
  gulp.watch(resource.dist.css).on("change", browserSync.reload)
  gulp.watch(resource.dist.js).on("change", browserSync.reload)

# run Web Server (gulp-webserver) [localhost:4567]
gulp.task "webserver", ->
  gulp.src(path.dist.root)
    .pipe(webserver({
      host: "0.0.0.0"
      port: 4567
      livereload: true
    }))
