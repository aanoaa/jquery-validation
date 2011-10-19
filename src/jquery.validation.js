(function() {
  $.fn.extend({
    vals: function() {
      var name, val;
      if (this.attr('type') === 'checkbox') {
        name = this.attr('name');
        return val = $("input[name=" + name + "]:checked").map(function() {
          return $(this).val();
        }).get().join(',');
      } else {
        return val = this.val();
      }
    },
    serializeObject: function() {
      var arrayData, objectData;
      arrayData = this.serializeArray();
      objectData = {};
      $.each(arrayData, function() {
        var value;
        if (this.value != null) {
          value = this.value;
        } else {
          value = '';
        }
        if (objectData[this.name] != null) {
          if (!objectData[this.name].push) {
            objectData[this.name] = [objectData[this.name]];
          }
          return objectData[this.name].push(value);
        } else {
          return objectData[this.name] = value;
        }
      });
      return objectData;
    },
    validation: function(options) {
      var opts, self;
      self = $.fn.validation;
      opts = $.extend({}, self.default_options, options);
      return $(this).each(function(i, el) {
        self.init(el, opts);
        $.each($(el).find(':text,textarea,:password'), function(j, input) {
          if ($(input).attr('type') !== 'submit') {
            return $(input).bind('focusout.validation', function() {
              return self.validate(this, opts);
            });
          }
        });
        return $(el).bind('submit.validation', function(e) {
          e.preventDefault();
          return self.validateAll(this, opts);
        });
      });
    }
  });
  $.extend($.fn.validation, {
    default_options: {
      log: true,
      debug: true,
      html: '<div class="validation" style="display:none;">\n  <p></p>\n</div>'
    },
    init: function(el, opts) {
      return $(document).trigger('init.validation', {
        parent: el,
        opts: opts
      });
    },
    log: function(msg) {
      return console.log(msg);
    },
    clear: function() {
      this.log('clear');
      return $('body > div.validation').each(function(i, el) {
        return $(el).fadeOut(function() {
          return $(this).remove();
        });
      });
    },
    validate: function(el, opts) {
      var offset, _name;
      offset = $(el).offset();
      offset.left += $(el).width();
      offset.top -= 35;
      offset.left -= 35;
      _name = $(el).attr('name');
      return $.ajax({
        type: 'POST',
        data: $(el).serializeObject(),
        dataType: 'json',
        url: opts.validateUrl,
        cache: false,
        beforeSend: function(jqXHR, settings) {
          if (!($("body > div.validation[title=" + _name + "]").length > 0)) {
            $(opts.html).addClass('validating').attr('title', _name).children('p').html('* validating.. please wait').parent().click(function() {
              return $(this).fadeOut(function() {
                return $(this).remove();
              });
            }).css({
              left: offset.left,
              top: offset.top
            }).fadeIn().appendTo('body');
          } else {
            $("body > div.validation[title=" + _name + "]").addClass('validating');
          }
          return $(document).trigger('beforeSend.validation', el);
        },
        success: function(data, textStatus, jqXHR) {
          if ($.isEmptyObject(data) || !(data[_name] != null)) {
            $("body > div.validation[title=" + _name + "]").fadeOut(function() {
              return $(this).remove();
            });
          } else {
            $("body > div.validation[title=" + _name + "]").removeClass('validating').children('p').html(data[_name]);
          }
          return $(document).trigger('afterSuccess.validation', el);
        },
        complete: function(jqXHR, textStatus) {}
      });
    },
    validateAll: function(el, opts) {
      this.clear();
      return $.ajax({
        type: 'POST',
        data: $(el).serialize(),
        dataType: 'json',
        url: opts.validateAllUrl,
        cache: false,
        beforeSend: function(jqXHR, settings) {
          return $(document).trigger('beforeSend.validation', el);
        },
        success: function(data, textStatus, jqXHR) {
          var scrollTop;
          if ($.isEmptyObject(data)) {
            $(el).unbind('submit.validation').submit();
          } else {
            scrollTop = 0;
            $.each(data, function(key, value) {
              var offset;
              offset = $("input[name=" + key + "],textarea[name=" + key + "]").offset();
              offset.left += $("input[name=" + key + "],textarea[name=" + key + "]").width();
              offset.top -= 35;
              offset.left -= 35;
              if (!scrollTop) {
                scrollTop = offset.top;
              }
              return $(opts.html).attr('title', key).children('p').html(value).parent().click(function() {
                return $(this).fadeOut(function() {
                  return $(this).remove();
                });
              }).css({
                left: offset.left,
                top: offset.top
              }).fadeIn().appendTo('body');
            });
          }
          if (scrollTop !== 0) {
            $("html:not(:animated),body:not(:animated)").animate({
              scrollTop: scrollTop
            }, 1100);
          }
          return $(document).trigger('afterSuccess.validation', el);
        },
        complete: function(jqXHR, textStatus) {}
      });
    }
  });
}).call(this);
