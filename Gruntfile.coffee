
module.exports = (grunt) ->

  karmaCfg =
    default:
      options:
        browsers: ["Chrome"]
        files: ["dist/jquery*.js", "test/fakeExt.coffee", "dist/linktoid.js", "test/*.css", "test/*.html", "test/*_spec.coffee"]
        singleRun: not grunt.option "debug"
        timeout: 120000
        preprocessors:
          "**/*.coffee": ["coffee"]
        frameworks: ["jasmine"]

  coffeeCfg =
    compile:
      files:
        "dist/linktoid.js": "src/linktoid.coffee"
      
  cfg =
    karma: karmaCfg
    coffee: coffeeCfg
  
  grunt.initConfig cfg

  grunt.loadNpmTasks "grunt-karma"
  grunt.loadNpmTasks "grunt-contrib-coffee"
  
  grunt.registerTask "compile", ["coffee"]
  grunt.registerTask "test", ["karma"]