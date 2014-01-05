###*jshint
###
### global
  define,
  exports,
  module
###

###*
 * accessifyhtml5.js - v2.0.2 - 2014-01-05
 * https://github.com/michsch/accessifyhtml5.js
 * original: https://github.com/yatil/accessifyhtml5.js
 * Copyright (c) 2013 Eric Eggert, Michael Schulze (AMD wrapper); Licensed MIT license
###

( ( root, factory, sr ) ->
  'use strict'

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
  'use strict'

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

    result =
      ok: []
      warn: []
      fail: []

    error = result.fail

    ATTR_SECURE = new RegExp('aria-[a-z]+|role|tabindex|title|alt|data-[\\w-]+|lang|' + 'style|maxlength|placeholder|pattern|required|type|target|accesskey|longdesc')
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

      # Either replace fixes...
      if more_fixes and more_fixes._CONFIG_ and more_fixes._CONFIG_.ignore_defaults
        fixes = more_fixes
      else

        # ..Or concatenate - the default.
        for mo of more_fixes
          fixes[mo] = more_fixes[mo]

      for fix of fixes
        continue  if fix.match(/^_(CONFIG|[A-Z]+)_/) # Silently ignore.
        if fixes.hasOwnProperty(fix)

          #Question: should we catch and report (or ignore) bad selector syntax?
          try
            elems = Doc.querySelectorAll(fix)
          catch ex
            error.push
              sel: fix
              attr: null
              val: null
              msg: 'Invalid syntax for `document.querySelectorAll` function'
              ex: ex

          obj = fixes[fix]
          if not elems or elems.length < 1
            result.warn.push
              sel: fix
              attr: null
              val: null
              msg: 'Not found'

          i = 0
          while i < elems.length
            for key of obj
              if obj.hasOwnProperty(key)
                attr = key
                value = obj[key]
                # Ignore notes/comments.
                continue  if attr.match(/_?note/)
                unless attr.match(ATTR_SECURE)
                  error.push
                    sel: fix
                    attr: attr
                    val: null
                    msg: 'Attribute not allowed'
                    re: ATTR_SECURE

                  continue
                unless (typeof value).match(/string|number|boolean/)
                  error.push
                    sel: fix
                    attr: attr
                    val: value
                    msg: 'Value-type not allowed'

                  continue

                # Connect up 'aria-labelledby'. //Question: do we accept poor spelling/ variations?
                by_match = attr.match(/(describ|label)l?edby/)
                if by_match
                  try
                    el_label = Doc.querySelector(value) #Not: elems[i].querySel()
                  catch ex
                    error.push
                      sel: fix
                      attr: attr
                      val: value
                      msg: "Invalid selector syntax (2) - see 'val'"
                      ex: ex

                  unless el_label
                    error.push
                      sel: fix
                      attr: attr
                      val: value
                      msg: "Labelledby ref not found - see 'val'"

                    continue
                  el_label.id = ID_PREFIX + n_label  unless el_label.id
                  value = el_label.id
                  attr = 'aria-' + ((if 'label' is by_match[1] then 'labelledby' else 'describedby'))
                  n_label++
                unless elems[i].hasAttribute(attr)
                  elems[i].setAttribute attr, value
                  result.ok.push
                    sel: fix
                    attr: attr
                    val: value
                    msg: "Added"

                else
                  result.warn.push
                    sel: fix
                    attr: attr
                    val: value
                    msg: 'Already present, skipped'

            i++

    result.input = fixes
    result
, 'AccessifyHTML5'
