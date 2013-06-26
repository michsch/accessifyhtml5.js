###*jshint
###
### global
  define,
  exports,
  module
###

###*
 * accessifyhtml5.js - v2.0.1 - 2013-06-26
 * https://github.com/michsch/accessifyhtml5.js
 * original: https://github.com/yatil/accessifyhtml5.js
 * Copyright (c) 2013 Eric Eggert, Michael Schulze (AMD wrapper); Licensed MIT license 
###

( ( root, factory, sr ) ->
  "use strict"

  # CommonJS
  if typeof exports is 'object'
    module.exports = factory()
  # AMD
  else if typeof define is 'function' and define.amd
    define factory
  # register as jQuery plugin
  else if typeof root.jQuery is 'function'
    root.jQuery[sr.toLowerCase()] = factory()
  # Browser
  else
    root[sr] = factory()

  true
) ( typeof window is 'object' and window ) or @, ->
  "use strict"

  ( defaults, more_fixes ) ->
    fixes =
      article:
        role: 'article'
      aside:
        role: 'complementary'
      nav:
        role: 'navigation'
      main:
        role: 'main'
      output:
        'aria-live': 'polite'
      section:
        role: 'region'
      '[required]':
        'aria-required': 'true'

    ATTR_SECURE = /aria-[a-z]+|role|tabindex|title|alt|data-[\w\-]+|lang|style|maxlength|placeholder|pattern|type/
    ID_PREFIX = 'acfy-id-'
    n_label = 0
    Doc = document

    if Doc.querySelectorAll

      if defaults
        fixes[defaults.header] = role: 'banner'  if defaults.header
        fixes[defaults.footer] = role: 'contentinfo'  if defaults.footer
        if defaults.main
          fixes[defaults.main] = role: 'main'
          fixes.main = role: ''

      for mo of more_fixes
        fixes[mo] = more_fixes[mo]

      for fix of fixes
        if fixes.hasOwnProperty(fix)
          
          #Question: should we catch and report (or ignore) bad selector syntax?
          elems = Doc.querySelectorAll(fix)
          obj = fixes[fix]
          i = 0

          while i < elems.length
            for key of obj
              if obj.hasOwnProperty(key)
                attr = key
                value = obj[key]
                
                #? console.log('Warning: attribute not allowed, ignoring: '+ attr); //Warn?
                continue  unless attr.match(ATTR_SECURE)
                
                #? console.log('Warning: value-type not allowed, ignoring: '+ typeof value); //Warn?
                continue  unless (typeof value).match(/string|number/)
                
                # Connect up 'aria-labelledby'. //Question: do we accept poor spelling/ variations?
                by_match = attr.match(/(describ|label)l?edby/)

                if by_match
                  el_label = Doc.querySelector(value) #Not: elems[i].querySel()
                  continue  unless el_label # Warn?
                  el_label.id = ID_PREFIX + n_label  unless el_label.id
                  value = el_label.id
                  attr = 'aria-' + ((if 'label' is by_match[1] then 'labelledby' else 'describedby'))
                  n_label++
                elems[i].setAttribute attr, value  unless elems[i].hasAttribute(attr)
            i++
    true
, 'AccessifyHTML5'