$ ->
  $('form').validation
    debug: on

  $(document).bind 'init.validation', (e, data) ->
    console.log "'init.validation' fired"
    console.log data.parent
    console.log data.opts
