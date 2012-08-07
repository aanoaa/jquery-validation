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
    opts = $.extend {}, self.default_options, options

    $(this).each (i, el) ->
      self.init el, opts
      $.each $(el).find(':text,textarea,:password'), (j, input) ->
        unless $(input).attr('type') is 'submit'
          $(input).bind 'focusout.validation', ->
            self.validate @, opts

      $(el).bind 'submit.validation', (e) ->
        e.preventDefault()
        self.validateAll @, opts

  jvclear: ->
    $('body > div.validation').each (i, el) ->
      $(el).fadeOut ->
        $(this).remove()

$.extend $.fn.validation,
  default_options:
    log: off
    debug: off
    validateUrl: window.location.href.split('#')[0]
    validateAllUrl: window.location.href.split('#')[0]
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

    $(document).trigger 'beforeValidate.validation', el

    $.ajax
      type: 'POST'
      data: $(el).serializeObject()
      dataType: 'json'
      url: opts.validateUrl
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
        if $.isEmptyObject(data) or !data[_name]?
          $("body > div.validation[title=#{_name}]").fadeOut ->
            $(this).remove()
        else
          $("body > div.validation[title=#{_name}]").removeClass('validating').children('p').html(data[_name])

        $(document).trigger 'afterSuccess.validation', el

      complete: (jqXHR, textStatus) ->
        # do something

  validateAll: (el, opts) ->
    do @clear
    $.ajax
      type: 'POST'
      data: $(el).serialize()
      dataType: 'json'
      url: opts.validateAllUrl
      cache: false
      beforeSend: (jqXHR, settings) ->
        $(document).trigger 'beforeSend.validation', el
      success: (data, textStatus, jqXHR) ->
        if $.isEmptyObject(data)
          $(document).trigger 'beforeSubmit.validation', el
          $(el).unbind('submit.validation').submit()
        else
          scrollTop = 0
          $.each data, (key, value) ->
            offset = $("input[name=#{key}],textarea[name=#{key}]").offset()
            return true unless offset
            offset.left += $("input[name=#{key}],textarea[name=#{key}]").width()
            offset.top -= 35
            offset.left -= 35
            scrollTop = offset.top unless scrollTop

            $(opts.html).attr('title', key).children('p').html(value).parent()
              .click ->
                $(this).fadeOut ->
                  $(this).remove()
              .css
                left: offset.left
                top: offset.top
              .fadeIn()
              .appendTo('body')

        $("html:not(:animated),body:not(:animated)").animate { scrollTop: scrollTop }, 1100 unless scrollTop is 0
        $(document).trigger 'afterSuccess.validation', el
      complete: (jqXHR, textStatus) ->
        # do something
