###
@name             Elastic
@descripton       Elastic is jQuery plugin that grow and shrink your textareas automatically
@version          1.6.11
@requires         jQuery 1.2.6+

@author           Jan Jarfalk
@author-email     jan.jarfalk@unwrongest.com
@author-website   http:#www.unwrongest.com

@licence          MIT License - http:#www.opensource.org/licenses/mit-license.php
###

define ["jquery"], (jQuery) ->

 jQuery.fn.extend
    elastic: ->

      # We will create a div clone of the textarea
      # by copying these attributes from the textarea to the div.
      mimics = [
        'paddingTop'
        'paddingRight'
        'paddingBottom'
        'paddingLeft'
        'fontSize'
        'lineHeight'
        'fontFamily'
        'width'
        'fontWeight'
        'border-top-width'
        'border-right-width'
        'border-bottom-width'
        'border-left-width'
        'borderTopStyle'
        'borderTopColor'
        'borderRightStyle'
        'borderRightColor'
        'borderBottomStyle'
        'borderBottomColor'
        'borderLeftStyle'
        'borderLeftColor'
      ]

      return @each ->
        # Elastic only works on textareas
        return false if @type isnt 'textarea'

        $textarea = jQuery(this)
        $twin     = jQuery('<div>').css
          'position'    : 'absolute'
          'display'     : 'none'
          'word-wrap'   : 'break-word'
          'white-space' : 'pre-wrap'

        lineHeight = minheight = maxheight = goalheight = 0

        setMeasurements = =>
          lineHeight  = parseInt($textarea.css('line-height'), 10) || parseInt($textarea.css('font-size'), 10)
          minheight   = parseInt($textarea.css('height'), 10)      || lineHeight * 3
          maxheight   = parseInt($textarea.css('max-height'), 10)  || Number.MAX_VALUE
          goalheight  = 0
 
        setMeasurements()

        # Opera returns max-height of -1 if not set
        maxheight = Number.MAX_VALUE if maxheight < 0

        # Append the twin to the DOM
        # We are going to meassure the height of this, not the textarea.
        $twin.appendTo $textarea.parent()

        # Copy the essential styles (mimics) from the textarea to the twin
        $twin.css(prop, $textarea.css(prop)) for prop in mimics

        # Updates the width of the twin. (solution for textareas with widths in percent)
        setTwinWidth = =>
          curatedWidth = Math.floor(parseInt($textarea.width(),10))
          if $twin.width() isnt curatedWidth
            $twin.css({'width': "#{curatedWidth}px"})

            # Update height of textarea
            update(true)

        # Sets a given height and overflow state on the textarea
        setHeightAndOverflow = (height, overflow) =>
          curratedHeight = Math.floor(parseInt(height,10))
          if $textarea.innerHeight() isnt curratedHeight
            $textarea.css({'height': "#{curratedHeight}px",'overflow':overflow})

        # This function will update the height of the textarea if necessary
        update = (forced) =>
          # Get curated content from the textarea.
          textareaContent = $textarea.val().replace(/&/g,'&amp').replace(new RegExp(' {2}','g'), '&nbsp').replace(/<|>/g, '&gt').replace(/\n/g, '<br />')

          # Compare curated content with curated twin.
          twinContent = $twin.html().replace(/<br>/ig,'<br />')

          if forced || "#{textareaContent}&nbsp" isnt twinContent

            # Add an extra white space so new rows are added when you are at the end of a row.
            $twin.html("#{textareaContent}&nbsp")

            # Change textarea height if twin plus the height of one line differs more than 3 pixel from textarea height
            if Math.abs($twin.innerHeight() + lineHeight - $textarea.innerHeight()) > 3

              goalheight = $twin.innerHeight()+lineHeight
              if goalheight >= maxheight
                setHeightAndOverflow(maxheight,'auto')
              else if goalheight <= minheight
                setHeightAndOverflow(minheight,'hidden')
              else
                setHeightAndOverflow(goalheight,'hidden')

        # Hide scrollbars
        $textarea.css overflow:'hidden'

        # Update textarea size on keyup, change, cut and paste
        $textarea.bind 'update keyup change cut paste', update

        # Update width of twin if browser or textarea is resized (solution for textareas with widths in percent)
        jQuery(window).bind 'resize', setTwinWidth
        $textarea.bind 'resize', setTwinWidth

        $textarea.bind 'focus', =>
          setMeasurements()
          setTwinWidth()

        # Compact textarea on blur
        $textarea.bind 'blur', =>
          if $twin.innerHeight() < maxheight
            if $twin.innerHeight() > minheight
              $textarea.height($twin.innerHeight())
            else
              $textarea.height(minheight)

        # And this line is to catch the browser paste event
        $textarea.bind 'input paste', (e) => setTimeout(update, 250)

        # Run update once when elastic is initialized
        update()

  return jQuery
