#     Hallo - a rich text editing jQuery UI widget
#     (c) 2011 Henri Bergius, IKS Consortium
#     Hallo may be freely distributed under the MIT license
((jQuery) ->
  jQuery.widget 'IKS.hallodropdownbutton',
    button: null

    options:
      uuid: ''
      label: null
      icon: null
      editable: null
      target: ''
      cssClass: null

    _create: ->
      @options.icon ?= "icon-#{@options.label.toLowerCase()}"

    _init: ->
      target = jQuery @options.target
      target.css 'position', 'absolute'
      target.addClass 'dropdown-target'

      target.hide()
      @button = @_prepareButton() unless @button

      @button.bind 'click', =>
        if target.hasClass 'open'
          @_hideTarget()
          return
        @_showTarget()

      target.bind 'click', =>
        @_hideTarget()

      @options.editable.element.bind 'hallodeactivated', =>
        @_hideTarget()

      @element.append @button

    _showTarget: ->
      target = jQuery @options.target   
      @_updateTargetPosition()
      target.addClass 'open'
      target.show()
    
    _hideTarget: ->
      target = jQuery @options.target     
      target.removeClass 'open'
      target.hide()

    _updateTargetPosition: ->
      target = jQuery @options.target
      {top, left} = @element.offset()
      {toolbarTop, toolbarLeft} = @options.editable.toolbar.offset()

      target.css 'top', left - toolbarLeft
      target.css 'left', top - toolbarTop

    _prepareButton: ->
      id = "#{@options.uuid}-#{@options.label}"
      buttonEl = jQuery """<button id=\"#{id}\" data-toggle=\"dropdown\" data-target=\"#{@options.target}\" title=\"#{@options.label}\">
          <span class="ui-button-text"><i class=\"#{@options.icon}\"></span></i>
        </button>"""
      buttonEl.addClass @options.cssClass if @options.cssClass

      button = buttonEl.button()
      button

)(jQuery)
