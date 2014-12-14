path = require "path"

module.exports = (grunt) ->

  karmaCfg =
    default:
      options:
        browsers: ["Chrome"]
        files: ["ext/jquery*.js", "test/fakeExt.coffee", "ext/linktoid.js", "test/*.css", "test/*.html", "test/*_spec.coffee"]
        singleRun: not grunt.option "debug"
        timeout: 120000
        preprocessors:
          "**/*.coffee": ["coffee"]
        frameworks: ["jasmine"]

  coffeeCfg =
    compile:
      files:
        "ext/linktoid.js": "src/linktoid.coffee"

  compressCfg = 
    public:
      options:
        archive: "dist/<%= pkg.name %>-<%= manifest.version %>.zip"
      files: [
        expand: true
        cwd: "ext/"
        src: ["**", "!.gitignore"]
        dest: ""
      ]
      
  zipToCrxCfg =
    options:
      privateKey: path.join process.env.USERPROFILE, ".keys", "LinkToId.pem"
    default:
      src: "dist/*.zip"
      dest: "dist/"
        
  cfg =
    karma: karmaCfg
    coffee: coffeeCfg
    compress: compressCfg
    zip_to_crx: zipToCrxCfg
    pkg: grunt.file.readJSON "package.json"
    manifest: grunt.file.readJSON "ext/manifest.json"
  
  grunt.initConfig cfg

  grunt.loadNpmTasks "grunt-karma"
  grunt.loadNpmTasks "grunt-contrib-coffee"
  grunt.loadNpmTasks "grunt-contrib-compress"
  grunt.loadNpmTasks "grunt-zip-to-crx"
  
  grunt.registerTask "compile", ["coffee"]
  grunt.registerTask "test", ["compile", "karma"]
  grunt.registerTask "package", ["compile", "compress"]
  grunt.registerTask "crx", ["package", "zip_to_crx"]
