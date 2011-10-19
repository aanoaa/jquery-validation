$.fn.extend
  vals: ->
    if @attr('type') is 'checkbox'
      name = @attr('name')
      val = $("input[name=#{name}]:checked").map ->
        $(this).val()
      .get().join(',')
    else
      val = @val()
  serializeObject: ->
    arrayData = this.serializeArray()
    objectData = {}

    $.each arrayData, () ->
      if this.value?
        value = this.value
      else
        value = ''

      if objectData[this.name]?
        unless objectData[this.name].push
          objectData[this.name] = [objectData[this.name]]

        objectData[this.name].push value
      else
        objectData[this.name] = value

    return objectData
  validation: (options) ->
    self = $.fn.validation
    $(this).each (i, el) ->
      opts = $.extend {}, self.default_options, options
      self.init el, opts
      $.each $(el).find(':text,textarea,:password'), (j, input) ->
        unless $(input).attr('type') is 'submit'
          $(input).bind 'focusout.validation', ->
            self.validate @, opts

      $(el).bind 'submit.validation', (e) ->
        e.preventDefault()
        self.validateAll @, opts

$.extend $.fn.validation,
  default_options:
    log: on
    debug: on
    html: '''
      <div class="validation" style="display:none;">
        <p></p>
      </div>
    '''

  init: (el, opts) ->
    $(document).trigger 'init.validation', { parent: el, opts: opts }

  log: (msg) ->
    console.log msg

  clear: ->
    @log 'clear'
    $('body > div.validation').each (i, el) ->
      $(el).fadeOut ->
        $(this).remove()

  validate: (el, opts) ->
    offset = $(el).offset()
    offset.left += $(el).width()
    # 닥치고 35
    offset.top -= 35
    offset.left -= 35

    _name = $(el).attr('name')

    $.ajax
      type: 'POST'
      data: $(el).serializeObject()
      dataType: 'json'
      url: '/fail.json'
      cache: false
      beforeSend: (jqXHR, settings) ->
        unless $("body > div.validation[title=#{_name}]").length > 0
          $(opts.html).addClass('validating').attr('title', _name)
            .children('p').html('* validating.. please wait').parent()
            .click ->
              $(this).fadeOut ->
                $(this).remove()
            .css
              left: offset.left
              top: offset.top
            .fadeIn()
            .appendTo('body')
        else
          $("body > div.validation[title=#{_name}]").addClass('validating')

        $(document).trigger 'beforeSend.validation', el
      success: (data, textStatus, jqXHR) ->
        if $.isEmptyObject(data)
          $("body > div.validation[title=#{_name}]").fadeOut ->
            $(this).remove()
        else
          $.each data, (key, value) ->
            $("body > div.validation[title=#{key}]").removeClass('validating').children('p').html(value)

        $(document).trigger 'afterSuccess.validation', el
      complete: (jqXHR, textStatus) ->
        # do something

  validateAll: (el, opts) ->
    do @clear
    $.ajax
      type: 'POST'
      data: $(el).serialize()
      dataType: 'json'
      # url: '/multiple.json'
      url: '/success.json'
      cache: false
      beforeSend: (jqXHR, settings) ->
        $(document).trigger 'beforeSend.validation', el
      success: (data, textStatus, jqXHR) ->
        if $.isEmptyObject(data)
          $(el).unbind('submit.validation').submit()
        else
          $.each data, (key, value) ->
            offset = $("input[name=#{key}],textarea[name=#{key}]").offset()
            offset.left += $("input[name=#{key}],textarea[name=#{key}]").width()
            offset.top -= 35
            offset.left -= 35

            $(opts.html).attr('title', key).children('p').html(value).parent()
              .click ->
                $(this).fadeOut ->
                  $(this).remove()
              .css
                left: offset.left
                top: offset.top
              .fadeIn()
              .appendTo('body')

        $(document).trigger 'afterSuccess.validation', el
      complete: (jqXHR, textStatus) ->
        # do something
