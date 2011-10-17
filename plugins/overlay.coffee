#   Hallo - a rich text editing jQuery UI widget
#   (c) 2011 Henri Bergius, IKS Consortium
#   Hallo may be freely distributed under the MIT license
#
# ============================================================
#
#   Hallo overlay plugin
#   (c) 2011 Liip AG, Switzerland
#   This plugin may be freely distributed under the MIT license.
#
#   The overlay plugin adds an overlay around the editable element.
#   It has no direct dependency with other plugins, but requires the
#   "floating" hallo option to be false to look nice. Furthermore, the
#   toolbar should have the same width as the editable element.
#
#   The options are documented in the code.
#

((jQuery) ->
    jQuery.widget "IKS.hallooverlay",
        options:
            editable: null
            toolbar: null
            uuid: ""
            overlay: null

        _create: ->
            widget = this

            if not @options.bound
                @options.bound = true
                widget.options.editable.element.bind "halloactivated", (event, data) ->
                    widget.options.currentEditable = jQuery(event.target)
                    widget.showOverlay()

                widget.options.editable.element.bind "hallomodified", (event, data) ->
                    if widget.options.visible
                        widget.updateOverlay()

                # abort editing when pressing ESCAPE --- This should be covered in hallo core, it's just not working yet
                widget.options.editable.element.keydown (event, data) ->
                    if event.keyCode == 27
                        widget.options.editable.restoreOriginalContent()
                        widget.options.editable.element.blur()
                        widget.hideOverlay()

                jQuery(window).resize ()->
                    if widget.options.visible
                        widget.updateOverlay(true)

        _init: ->

        showOverlay: ->
            @options.visible = true
            if @options.overlay
                @options.overlay.show


                @options.originalBgColor = @options.currentEditable.css "background-color"
                @options.currentEditable.css 'background-color', _findBackgroundColor(@options.currentEditable)
                @options.originalZIndex = @options.currentEditable.css "z-index"
                @options.currentEditable.css 'z-index', '350'

            @_createOverlay()

        hideOverlay: ->
            @options.visible = false
            @options.overlay.hide

            @options.currentEditable.css 'background-color', @options.originalBgColor
            @options.currentEditable.css 'z-index', originalZIndex

            @options.editable._deactivated {data: @options.editable}

        _createOverlay: () ->
            overlay = jQuery('<div class="halloOverlay">')
            jQuery(document.body).append overlay
            overlay.bind 'click', jQuery.proxy @hideOverlay, @

        _findBackgroundColor: (field) ->
            jQueryfield = jQuery(field)
            color = jQueryfield.css("background-color")
            if color isnt 'rgba(0,0,0,0)' and color isnt 'transparent'
                return color

            if jQueryfield.is "body"
                return false;
            else
                return _findBackgroundColor(jQueryfield.parent())

)(jQuery)