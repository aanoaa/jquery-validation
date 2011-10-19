$ ->
  $(document).bind 'init.validation', (e, data) ->
    console.log "'init.validation' fired"
    console.log data.parent
    console.log data.opts

  $('form').validation
    debug: on
    validateUrl: '/json/fail.json'
    validateAllUrl: '/json/multiple.json'
    # validateAllUrl: '/json/success.json'
