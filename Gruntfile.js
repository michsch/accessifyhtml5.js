module.exports = function(grunt) {
  "use strict";

  // Project configuration.
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),
    meta: {
      banner: '<%= pkg.title || pkg.name %> - v<%= pkg.version %> - ' +
        '<%= grunt.template.today("yyyy-mm-dd") + "\\n" %>' +
        '<%= pkg.homepage ? " * " + pkg.homepage + "\\n" : "" %>' +
        '<%= pkg.forked ? " * original: " + pkg.forked + "\\n" : "" %>' +
        ' * Copyright (c) <%= grunt.template.today("yyyy") %> <%= pkg.author.name %>;' +
        ' Licensed <%= _.pluck(pkg.licenses, "type").join(", ") %>',
      bannercoffee: '###*\n * <%= meta.banner %> \n###',
      bannerjs: '/*! <%= meta.banner %> */\n'
    },
    'string-replace': {
      comment: {
        files: {
          './': [ 'module/**/*.coffee' ]
        },
        options: {
          replacements: [{
            pattern: /###\*(\n|\r|(\r\n))(.|\n|\r|(\r\n))*###/i,
            replacement: '<%= meta.bannercoffee %>'
          }]
        }
      }
    },
    coffee: {
      options: {
        bare: true
      },
      module: {
        expand: true,
        cwd: 'module/coffee/',
        src: [ '**/*.coffee' ],
        dest: 'module/',
        rename: function( destPath, srcPath ) {
          var dest;
          dest = destPath + srcPath.replace(/\.coffee$/,".js");
          return dest;
        }
        //ext: '.js'
      }
    },
    jshint: {
      options: {
        jshintrc: 'module/.jshintrc'
      },
      gruntfile: {
        options: {
          jshintrc: '.jshintrc'
        },
        src: [ 'Gruntfile.js' ]
      },
      original: {
        src: [
          'accessifyhtml5.jquery.js',
          'accessifyhtml5.js'
        ]
      },
      module: {
        options: {
          jshintrc: 'module/.jshintrc'
        },
        src: [
          'module/accessifyhtml5.js'
        ]
      },
      test: {
        files: {
          src: [ 'test/**/*.js' ]
        }
      }
    },
    uglify: {
      prod: {
        options : {
          banner: '<%= meta.bannerjs %>'
        },
        files: {
          'module/accessifyhtml5.min.js' : [ 'module/accessifyhtml5.js' ]
        }
      }
    },
    watch: {
      module: {
        files: [
          'Gruntfile.js',
          'module/coffee/**/*.coffee'
        ],
        tasks: 'module'
      }
    }
  });

  // Load grunt-compass plugin
  grunt.loadNpmTasks( 'grunt-contrib-coffee' );
  grunt.loadNpmTasks( 'grunt-contrib-jshint' );
  grunt.loadNpmTasks( 'grunt-contrib-uglify' );
  grunt.loadNpmTasks( 'grunt-contrib-watch' );
  grunt.loadNpmTasks( 'grunt-string-replace' );

  grunt.registerTask( 'comment', [ 'string-replace:comment' ]);

  grunt.registerTask( 'module', [
      'coffee',
      'jshint:module',
      'uglify'
  ]);

  // Default task.
  grunt.registerTask('default', 'watch:module');
};