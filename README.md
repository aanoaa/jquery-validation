jquery-validation
=================

jquery-validation is jQuery-based, validation engine on ajax.


Usage
-----

```coffeescript
$ ->
  $(document).bind 'init.validation', (e, data) ->
    console.log "'init.validation' fired"
    console.log data.parent
    console.log data.opts
    $(data.parent).validation
      clear: true

  $('form').validation
    debug: on
    validateUrl: '/json/fail.json'
    validateAllUrl: '/json/multiple.json'
```

### event

- init.validation
- beforeValidate.validation
- beforeSend.validation
- afterSuccess.validation


### options

- log: true|false
- debug: true|false
- validateUrl: wth..
- validateAllUrl: wth..


SEE ALSO
--------

[jQuery-Validation-Engine/README.md](https://github.com/posabsolute/jQuery-Validation-Engine/blob/master/README.md)
