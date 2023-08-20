import $ from "cash-dom";

// Handles the hover bar for modifying widgets 
export default class {

  constructor(pageController) {
    this.current_handle = null;
    this.enabled = true;
    this.pageController = pageController;
  }

  init() {
  }

  setEnabled(val) {
    this.enabled = val;
  }

  setHandle(handle) {
    // Cancel any running effects
    if (this.current_handle)
      this.current_handle.stop().show().css('opacity', 1.0);

    var is_new = this.current_handle == null || (this.current_handle[0] != handle[0]);
    //if (is_new)
      //console.log('handle=' + handle.attr('id'), 'current_handle=' + (this.current_handle == null ? null : this.current_handle.attr('id')));

    // Different handle, make sure the old one is gone
    if (this.current_handle && is_new)
      this.current_handle.hide();

        // Show the new handle
    if (is_new || handle.is(':hidden'))
      handle.css('opacity', 1.0).show();

        // Disable insertion marker
    if (this.pageController.insertionMarker.enabled)
    {
      this.pageController.insertionMarker.setEnabled(false);
      this.pageController.insertionMarker.hide();
    }

    this.current_handle = handle;
  }

  clearHandle() {
    if (!this.current_handle)
      return;

    if (!this.enabled)
    {
      this.current_handle.hide();
      return;
    }

        // Make sure the old one vanishes
    if (!this.current_handle.is(':animated'))
    {
      this.current_handle.fadeOut(800, function() { this.current_handle = null; });
    }

    if (!this.pageController.insertionMarker.enabled)
    {
      this.pageController.insertionMarker.setEnabled(true);
    }
  }
};
