module.exports = function(grunt) {
  "use strict";

  var tasks, gruntConfig;

  // define tasks
  // files to watch
  tasks = {
    files : [
      'Gruntfile.js',
      'module/coffee/**/*.coffee'
    ]
  };

  tasks.module = {
    name: 'module',
    tasks: [
      'string-replace:comment',
      'coffee',
      'jshint:module',
      'uglify'
    ]
  };

  if (tasks.module.files === void 0) {
    tasks.module.files = tasks.files;
  }

  // Project configuration.
  gruntConfig = {
    pkg: grunt.file.readJSON('package.json'),
    // Project metadata, used by some directives, helpers and tasks.
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
      glob_to_multiple: {
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
        curly: true,
        eqeqeq: true,
        immed: false,
        latedef: true,
        newcap: true,
        noarg: true,
        sub: true,
        undef: true,
        boss: true,
        eqnull: true,
        browser: true,
        jquery: true,
        globals: {}
      },
      grunt: {
        options: {
          node: true,
          strict : true,
          globals: {
            module: true
          }
        },
        files: {
          src: ['Gruntfile.js']
        }
      },
      original: {
        files: {
          src: [
            'accessifyhtml5.jquery.js',
            'accessifyhtml5.js'
          ]
        }
      },
      module: {
        options: {
          globals: {
            define: true,
            module: true
          }
        },
        files: {
          src: [
            'module/accessifyhtml5.js'
          ]
        }
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
        files: tasks.module.files,
        tasks: tasks.module.tasks
      }
    }
  };

  grunt.initConfig( gruntConfig );

    // Load grunt-compass plugin
  grunt.loadNpmTasks('grunt-contrib-coffee');
  grunt.loadNpmTasks('grunt-contrib-jshint');
  grunt.loadNpmTasks('grunt-contrib-uglify');
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-string-replace');

  grunt.registerTask(tasks.module.name, tasks.module.tasks);

  // Default task.
  grunt.registerTask('default', 'watch:' + tasks.module.name);
};