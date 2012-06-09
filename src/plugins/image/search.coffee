#     Hallo - a rich text editing jQuery UI widget
#     (c) 2012 Henri Bergius, IKS Consortium
#     Hallo may be freely distributed under the MIT license
((jQuery) ->
  jQuery.widget 'IKS.halloimagesearch',
    options:
      imageWidget: null
      searchCallback: null
      limit: 5

    _create: ->
      @element.html '<div>
        <form method="get">
          <input type="text" class="searchInput" />
          <input type="submit" class="btn searchButton" value="OK" />
        </form>
        <div class="searchResults imageThumbnailContainer">
          <div class="activitySpinner">Loading images...</div>
          <ul></ul>
        </div>
      </div>'

    _init: ->
      widget = @
      jQuery('.activitySpinner', @element).hide()

      jQuery('form', @element).submit (event) ->
        event.preventDefault()

        jQuery('.activitySpinner', @element).show()

        query = jQuery('.searchInput', widget.element).val()
        widget.options.searchCallback query, widget.options.limit, 0, (results) ->
          widget._showResults results

    _showResult: (image) ->
      html = jQuery "<li><img src=\"#{image.url}\" class=\"imageThumbnail\" title=\"#{image.label}\"></li>"
      html.bind 'click', =>
        @options.imageWidget.setCurrent image
      jQuery('.imageThumbnailContainer ul', @element).append html

    _showNextPrev: (results) ->
      widget = @

      container = jQuery 'imageThumbnailContainer ul', @element
      container.prepend jQuery '<div class="pager-prev" style="display:none"></div>'
      container.append jQuery '<div class="pager-next" style="display:none"></div>'

      jQuery('.pager-prev', container).show() if response.offset > 0
      jQuery('.pager-next', container).show() if response.offset < response.total

      jQuery('.pager-prev', container).click (event) ->
          widget.options.searchCallback query, widget.options.limit, response.offset - widget.options.limit, (results) ->
            widget._showResults results
       jQuery('.pager-next', container).click (event) ->
          widget.options.searchCallback query, widget.options.limit, response.offset + widget.options.limit, (results) ->
            widget._showResults results

    _showResults: (results) ->
      jQuery('.activitySpinner', @element).hide()
      jQuery('imageThumbnailContainer ul', @element).empty()
      jQuery('imageThumbnailContainer ul', @element).show()

      @_showResult image for image in results.assets

      @options.imageWidget.setCurrent results.assets.shift()

      @_showNextPrev results

) jQuery
