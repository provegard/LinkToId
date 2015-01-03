###
Copyright (c) 2012-2014 Per Rovegard, http://rovegard.com
The contents of this file are subject to the terms and conditions of the MIT 
license, see http://per.mit-license.org/2012.
###

window[chrome.i18n.getMessage "@@extension_id"] = do (module = window[chrome.i18n.getMessage "@@extension_id"] or {}) ->
  
  extId          = chrome.i18n.getMessage "@@extension_id"
  tooltipClass   = "tt-#{extId}"
  tooltipElement = null
  location       = window.location
  
  # Get the distance from the top of an element to the "page top".
  getElementTop = (e) ->
    top = 0

    # Walk the offset parent hierarchy upwards until we hit the body element.
    # The sum of all offsetTop values is equal to the verticial distance from
    # the "page top".
    while e? and e.tagName != "BODY"
      top += e.offsetTop
      e = e.offsetParent
   
    top

  # Determines if an event is active/triggering. To make this extension
  # more useful, the condition should be configurable.
  isActive = (event) -> event.ctrlKey and event.altKey

  # Determines if an element is a block element.
  isBlock = (e) ->
    cs = window.getComputedStyle e, ""
    cs.display == "block"

  # Removes the tooltip if it's found. Otherwise, does nothing.
  removeTooltip = -> 
    tooltip = findTooltip()
    if tooltip
      tooltip.parentNode.removeChild tooltip

  # Determines if an element has a non-empty ID attribute.
  hasId = (e) -> (e.id or "").length > 0

  # Given a candidate element, walks the DOM hierarchy upwards until it finds
  # an element with a non-empty ID attribute. Returns the element found, or
  # null.
  findTarget = (candidate) ->
    target = candidate
    top = getElementTop target
    while target? and not hasId target
      target = target.parentNode
    if target? and hasId target then target else null
  
  # Determines if the supplied ID matches the fragment/hash of the Location object.
  idMatchesHash = (id) -> "#" + id == location.hash
  
  # Used as a click handler. Updates the fragment/hash if the event is active
  # and a suitable target element can be found. Any showing tooltip is removed.
  update = (event) ->
    return unless isActive event
    
    target = findTarget event.target

    # Update the hash (fragment) if we have a target, but only if
    # the current hash isn't already equal to the target ID.
    if target? and not idMatchesHash target.id
      # Prevent default processing of this event.
      event.preventDefault()
      
      removeTooltip()
      location.hash = target.id
  
  # Finds the currently showing tooltip. Returns the jQuery object if found,
  # undefined  otherwise.
  findTooltip = -> document.getElementsByClassName(tooltipClass)[0]
  
  # Creates the text to be used for the tooltip.
  createTooltipText = (id, distance) ->
    htmlText = "Click to navigate to <span>##{id}</span>!"
    if distance
      htmlText += " It's #{distance} pixels to the north, by the way."
    htmlText
  
  # Used as a mouse move handler. Creates the tooltip if necessary, otherwise
  # simply moves it to the correct location. If the current fragment/hash is
  # equal to the ID of the target element, no tooltip is created.
  enter = (event) ->
    if isActive event
      target = findTarget event.target

      # Add a class if we have a target!
      if target? and not idMatchesHash target.id
        tooltip = findTooltip()
        unless tooltip
          # No active tooltip. Use the existing element if it has been created,
          # otherwise create it.
          unless tooltipElement
            tooltipElement = document.createElement 'SPAN'
            tooltipElement.className = tooltipClass
          tooltip = tooltipElement
            
          # The tooltip is added as a child to BODY so that the position becomes
          # relative to the page rather than a specific element.
          body = document.getElementsByTagName('BODY')[0]
          body.appendChild tooltip

        # Update the tooltip text
        distance = event.pageY - getElementTop target
        htmlText = createTooltipText target.id, distance
        tooltip.innerHTML = htmlText

        # Position the tooltip adjacent to the mouse location.
        tooltip.style.top = event.pageY + 'px'
        tooltip.style.left = (event.pageX + 10) + 'px'
    else
      removeTooltip()
  
  # Removes any showing tooltip.
  leave = -> removeTooltip()
  
  # Removes any showing tooltip if the event isn't an active one.
  cancel = (event) -> removeTooltip() unless isActive event

  document.addEventListener 'mousedown', update
  document.addEventListener 'keyup', cancel
  document.addEventListener 'mousemove', enter
  document.addEventListener 'mouseout', leave

  # Exported for testing
  module.exports =
    isBlock: isBlock
    hasId: hasId
    findTarget: findTarget
    getElementTop: getElementTop
  
  module