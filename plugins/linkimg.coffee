#     Hallo - a rich text editing jQuery UI widget
#     (c) 2011 Henri Bergius, IKS Consortium
#     Hallo may be freely distributed under the MIT license
((jQuery) ->
    jQuery.widget "IKS.hallolinkimg",
        options:
            editable: null
            toolbar: null
            uuid: ""
            link: true
            image: true
            defaultUrl: 'http://'
            dialogOpts:
                autoOpen: false
                width: 540
                height: 120
                title: "Enter Link"
                modal: true
                resizable: false
                draggable: true

        _create: ->
            widget = this

            dialogId = "#{@options.uuid}-dialog"
            dialog = jQuery "<div id=\"#{dialogId}\"><form action=\"#\" method=\"post\" class=\"linkForm\"><input class=\"url\" type=\"text\" name=\"url\" size=\"40\" value=\"#{@options.defaultUrl}\" /><input type=\"submit\" value=\"Insert\" /></form></div>"
            urlInput = jQuery('input[name=url]', dialog).focus (e)->
                this.select()
            dialogSubmitCb = () ->
                link = urlInput.val()
                widget.options.editable.restoreSelection(widget.lastSelection)
                if ((new RegExp(/^\s*$/)).test link) or link is widget.options.defaultUrl
                    # link is empty, remove it
                    widget.lastSelection.selectNode widget.lastSelection.startContainer
                    document.execCommand "unlink", null, ""
                else
                    if widget.lastSelection.startContainer.parentNode.href is undefined
                        document.execCommand "createLink", null, link
                    else
                        widget.lastSelection.startContainer.parentNode.href = link
                widget.options.editable.removeAllSelections()
                dialog.dialog('close')
                return false
            dialog.find("form").submit dialogSubmitCb

            buttonset = jQuery "<span class=\"#{widget.widgetName}\"></span>"
            buttonize = (type) =>
                id = "#{@options.uuid}-#{type}"
                buttonset.append jQuery("<input id=\"#{id}\" type=\"checkbox\" /><label for=\"#{id}\" class=\"anchor_button\" >#{type}</label>").button()
                button = jQuery "##{id}", buttonset
                button.bind "change", (event) ->
                    # we need to save the current selection because we will lose focus
                    widget.lastSelection = widget.options.editable.getSelection()
                    urlInput = jQuery('input[name=url]', dialog);
                    if widget.lastSelection.startContainer.parentNode.href is undefined
                        urlInput.val(widget.options.defaultUrl)
                    else
                        urlInput.val(jQuery(widget.lastSelection.startContainer.parentNode).attr('href'))
                        jQuery(urlInput[0].form).find('input[type=submit]').val('update')

                    dialog.dialog('open')

                @element.bind "keyup paste change mouseup", (event) ->
                    if jQuery(event.target)[0].nodeName is "A"
                        button.attr "checked", true
                        button.next().addClass "ui-state-clicked"
                        button.button "refresh"
                    else
                        button.attr "checked", false
                        button.next().removeClass "ui-state-clicked"
                        button.button "refresh"

            if (@options.link)
                buttonize "A"

            if (@options.link)
                buttonset.buttonset()
                @options.toolbar.append buttonset
                dialog.dialog(@options.dialogOpts)

        _init: ->

)(jQuery)