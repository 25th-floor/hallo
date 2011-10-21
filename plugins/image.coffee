#     Hallo - a rich text editing jQuery UI widget
#     (c) 2011 Henri Bergius, IKS Consortium
#     Hallo may be freely distributed under the MIT license
((jQuery) ->
    jQuery.widget "IKS.halloimage",
        options:
            editable: null
            toolbar: null
            uuid: ""
            searchUrl: "liip/vie/assets/search/" # TODO: pass this in, set default to ""
            dialogOpts:
                autoOpen: false
                width: 270
                height: 500
                title: "Insert Images"
                modal: false
                resizable: false
                draggable: true
                dialogClass: 'halloimage-dialog'
                close: (ev, ui) ->
                    jQuery('.image_button').removeClass('ui-state-clicked')
            dialog: null

        _create: ->
            widget = this

            dialogId = "#{@options.uuid}-image-dialog"
            @options.dialog = jQuery "<div id=\"#{dialogId}\">
            <div class=\"nav\">
                <ul class=\"tabs\">
                    <li id=\"#{@options.uuid}-tab-suggestions\"><img src=\"/bundles/liipvie/img/tabicon_suggestions.png\" /> Suggestions</li>
                    <li id=\"#{@options.uuid}-tab-search\"><img src=\"/bundles/liipvie/img/tabicon_search.png\" /> Search</li>
                    <li id=\"#{@options.uuid}-tab-upload\"><img src=\"/bundles/liipvie/img/tabicon_upload.png\" /> Upload</li>
                </ul>
                <img src=\"/bundles/liipvie/img/arrow.png\" id=\"#{@options.uuid}-tab-activeIndicator\" class=\"tab-activeIndicator\" />
            </div>
            <div class=\"dialogcontent\">
                <div id=\"#{@options.uuid}-tab-suggestions-content\" class=\"#{widget.widgetName}-tab tab-suggestions\">
                    <div>
                        <img src=\"http://imagesus.homeaway.com/mda01/badf2e69babf2f6a0e4b680fc373c041c705b891\" class=\"imageThumbnail imageThumbnailActive\" />
                        <img src=\"http://www.ngkhai.net/cebupics/albums/userpics/10185/thumb_P1010613.JPG\" class=\"imageThumbnail\" />
                        <img src=\"http://idiotduck.com/wp-content/uploads/2011/03/amazing-nature-photography-waterfall-hdr-1024-768-14-150x200.jpg\" class=\"imageThumbnail\" />
                        <img src=\"http://photos.somd.com/data/14/thumbs/20080604_9-1.JPG\" class=\"imageThumbnail\" />
                        <img src=\"http://www.hotfrog.com.au/Uploads/PressReleases2/THAILAND-TRAVEL-PACKAGES-THAILAND-BEACH-TOURS-THAILAND-VACATION-SUNRISE-PHUKET-BEACH-TOUR-200614_image.jpg\" class=\"imageThumbnail\" />
                        <img src=\"http://photos.somd.com/data/14/thumbs/SunriseMyrtleBeach2008.jpg\" class=\"imageThumbnail\" />
                        <img src=\"http://www.zsqts.com.cn/product-photo/2009-07-17/a411bfd382731251ae26bfb311c30629/Buy-best-buy-fireworks-from-China-Liuyang-SKY-PIONEER-PYROTECHNICS-INC.jpg\" class=\"imageThumbnail\" />
                        <img src=\"http://www.costumeattic.com/images_product/preview/Rubies/885106.jpg\" class=\"imageThumbnail\" />
                    </div>
                    <div class=\"activeImageContainer\">
                        <div class=\"rotationWrapper\">
                            <div class=\"hintArrow\"></div>
                            <img src=\"\" id=\"#{@options.uuid}-sugg-activeImage\" class=\"activeImage\" />
                        </div>
                        <img src=\"\" id=\"#{@options.uuid}-sugg-activeImageBg\" class=\"activeImage activeImageBg\" />
                    </div>
                    <div class=\"metadata\">
                        <label for=\"caption\">Caption</label><input type=\"text\" id=\"caption\" />
                        <button id=\"#{@options.uuid}-#{widget.widgetName}-addimage\">Add Image</button>
                    </div>
                </div>
                <div id=\"#{@options.uuid}-tab-search-content\" class=\"#{widget.widgetName}-tab tab-search\">
                    <form action=\"#{widget.options.searchUrl}/?page=1&length=4\" type=\"get\" id=\"#{@options.uuid}-#{widget.widgetName}-searchForm\">
                        <input type=\"text\" class=\"searchInput\" /><input type=\"submit\" id=\"#{@options.uuid}-#{widget.widgetName}-searchButton\" class=\"button searchButton\" value=\"OK\"/>
                    </form>
                    <div class=\"searchResults\"></div>
                    <div id=\"#{@options.uuid}-search-activeImageContainer\" class=\"search-activeImageContainer activeImageContainer\">
                        <div class=\"rotationWrapper\">
                            <div class=\"hintArrow\"></div>
                            <img src=\"\" id=\"#{@options.uuid}-search-activeImageBg\" class=\"activeImage\" />
                        </div>
                        <img src=\"\" id=\"#{@options.uuid}-search-activeImage\" class=\"activeImage activeImageBg\" />
                    </div>
                </div>
                <div id=\"#{@options.uuid}-tab-upload-content\" class=\"#{widget.widgetName}-tab tab-upload\">UPLOAD</div>
            </div></div>"

            jQuery(".tab-search form", @options.dialog).submit (event) ->
                event.preventDefault()
                that = this

                showResults = (response) ->
                    items = []
                    items.push("<div class=\"pager-prev\" style=\"display:none\"></div>");
                    $.each response.assets, (key, val) ->
                        items.push("<img src=\"#{val.url}\" class=\"imageThumbnail #{widget.widgetName}-search-imageThumbnail\" /> ");
                    items.push("<div class=\"pager-next\" style=\"display:none\"></div>");

                    container = jQuery("##{dialogId} .tab-search .searchResults")
                    container.html(items.join(''))

                    # handle pagers
                    if response.page > 1
                        jQuery('.pager-prev', container).show()
                    if response.page < Math.ceil(response.total/response.length)
                        jQuery('.pager-next', container).show()

                    jQuery('.pager-prev', container).click (event) ->
                        search(response.page - 1)
                    jQuery('.pager-next', container).click (event) ->
                        search(response.page + 1)

                    # Add action to image thumbnails
                    jQuery("##{widget.options.uuid}-search-activeImageContainer").show()
                    firstimage = jQuery(".#{widget.widgetName}-search-imageThumbnail").first().addClass "imageThumbnailActive"
                    jQuery("##{widget.options.uuid}-search-activeImage, ##{widget.options.uuid}-search-activeImageBg").attr "src", firstimage.attr "src"

                search = (page) ->
                    page = page || 1
                    jQuery.ajax({
                        type: "GET",
                        url: widget.options.searchUrl,
                        data: "page=#{page}&length=4",
                        success: showResults
                    })

                search()

            insertImage = () ->
                #This may need to insert an image that does not have the same URL as the preview image, since it may be a different size

                # Check if we have a selection and fall back to @lastSelection otherwise
                try
                    if not widget.options.editable.getSelection()
                        throw new Error "SelectionNotSet"
                catch error
                    widget.options.editable.restoreSelection(widget.lastSelection)

                document.execCommand "insertImage", null, $(this).attr('src')
                img = document.getSelection().anchorNode.firstChild
                jQuery(img).attr "alt", jQuery(".caption").value

                triggerModified = () ->
                    widget.element.trigger "hallomodified"
                window.setTimeout triggerModified, 100
                widget._closeDialog()

            @options.dialog.find(".halloimage-activeImage, ##{widget.options.uuid}-#{widget.widgetName}-addimage").click insertImage

            buttonset = jQuery "<span class=\"#{widget.widgetName}\"></span>"

            id = "#{@options.uuid}-image"
            buttonset.append jQuery("<input id=\"#{id}\" type=\"checkbox\" /><label for=\"#{id}\" class=\"image_button\" >Image</label>").button()
            button = jQuery "##{id}", buttonset
            button.bind "change", (event) ->
                if widget.options.dialog.dialog "isOpen"
                    widget._closeDialog()
                else
                    widget._openDialog()

            @options.editable.element.bind "hallodeactivated", (event) ->
                widget._closeDialog()

            jQuery(@options.editable.element).delegate "img", "click", (event) ->
                widget._openDialog()

            jQuery(@options.dialog).find(".nav li").click () ->
                jQuery(".#{widget.widgetName}-tab").each () ->
                    jQuery(this).hide()

                id = jQuery(this).attr("id")
                jQuery("##{id}-content").show()
                jQuery("##{widget.options.uuid}-tab-activeIndicator").css("margin-left", jQuery(this).position().left + (jQuery(this).width()/2))

            # Add action to image thumbnails
            jQuery(".#{widget.widgetName}-tab .imageThumbnail").live "click", (event) ->
                scope = jQuery(this).closest(".#{widget.widgetName}-tab")
                jQuery(".imageThumbnail", scope).removeClass "imageThumbnailActive"
                jQuery(this).addClass "imageThumbnailActive"
                jQuery(".activeImage", scope).attr "src", jQuery(this).attr "src"
                jQuery(".activeImageBg", scope).attr "src", jQuery(this).attr "src"

            buttonset.buttonset()
            @options.toolbar.append buttonset
            @options.dialog.dialog(@options.dialogOpts)

        _init: ->

        _openDialog: ->
            # Update state of button in toolbar
            jQuery('.image_button').addClass('ui-state-clicked')

            # Update active Image
            jQuery("##{@options.uuid}-sugg-activeImage").attr "src", jQuery("##{@options.uuid}-tab-suggestions-content .imageThumbnailActive").first().attr "src"
            jQuery("##{@options.uuid}-sugg-activeImageBg").attr "src", jQuery("##{@options.uuid}-tab-suggestions-content .imageThumbnailActive").first().attr "src"

            # Save current caret point
            @lastSelection = @options.editable.getSelection()

            # Position correctly
            xposition = jQuery(@options.editable.element).offset().left + jQuery(@options.editable.element).outerWidth() - 3 # 3 is the border width of the contenteditable border
            yposition = jQuery(@options.toolbar).offset().top - jQuery(document).scrollTop() - 29
            @options.dialog.dialog("option", "position", [xposition, yposition])
            @options.dialog.dialog("open")

        _closeDialog: ->
            @options.dialog.dialog("close")

)(jQuery)
