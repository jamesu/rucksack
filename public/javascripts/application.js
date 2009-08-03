// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

// TODO: re-write and consolidate where needed

// Quick jQuery extensions for missing prototype functions

jQuery.fn.extend({
  request: function( callback, type ) {
   var el = $(this[0]);
	 return jQuery.ajax({
	   type: el.attr('method'),
	   url: el.attr('action'),
	   data: el.serialize(),
	   success: callback,
	   dataType: type
	 });
	},
	
	requestIframeScript: function( params, callback ) {
	  var strName = ("uploader" + (new Date()).getTime());
	  var jFrame = $( "<iframe name=\"" + strName + "\" src=\"about:blank\" />" );
	  jFrame.css( "display", "none" );

	  jFrame.load(function(evt){
	    var objUploadBody = window.frames[ strName ].document.getElementsByTagName( "body" )[ 0 ];
	    var jBody = $(objUploadBody);
	    
	    // Safari fix
	    if (!objUploadBody.innerHTML)
	      return;
	    
	    // Ugly hack
	    $.get(objUploadBody.innerHTML, params, callback, 'script');
	    
	    setTimeout(function(){
	      jFrame.remove();
	    }, 800);
	  });
	  
	  $("body:first").append(jFrame);	  
	  $(this[0]).attr('target', strName);
	},
	
	autofocus: function() {
	  this.find('.autofocus:first').focus();
	}
});

/**
 * .disableTextSelect - Disable Text Select Plugin
 *
 * Version: 1.1
 * Updated: 2007-11-28
 *
 * Used to stop users from selecting text
 *
 * Copyright (c) 2007 James Dempster (letssurf@gmail.com, http://www.jdempster.com/category/jquery/disabletextselect/)
 *
 * Dual licensed under the MIT (MIT-LICENSE.txt)
 * and GPL (GPL-LICENSE.txt) licenses.
 **/
(function($) {
    if ($.browser.mozilla) {
        $.fn.disableTextSelect = function() {
            return this.each(function() {
                $(this).css({
                    'MozUserSelect' : 'none'
                });
            });
        };
        $.fn.enableTextSelect = function() {
            return this.each(function() {
                $(this).css({
                    'MozUserSelect' : ''
                });
            });
        };
    } else if ($.browser.msie) {
        $.fn.disableTextSelect = function() {
            return this.each(function() {
                $(this).bind('selectstart.disableTextSelect', function() {
                    return false;
                });
            });
        };
        $.fn.enableTextSelect = function() {
            return this.each(function() {
                $(this).unbind('selectstart.disableTextSelect');
            });
        };
    } else {
        $.fn.disableTextSelect = function() {
            return this.each(function() {
                $(this).bind('mousedown.disableTextSelect', function() {
                    return false;
                });
            });
        };
        $.fn.enableTextSelect = function() {
            return this.each(function() {
                $(this).unbind('mousedown.disableTextSelect');
            });
        };
    }
})(jQuery);
/** END OF disableTextSelect **/


// jQuery object extensions

jQuery.extend({
  del: function( url, data, callback, type ) {
		if ( jQuery.isFunction( data ) ) {
			callback = data;
			data = {};
		}
		
		data = data == null ? {} : data;
		if (!data['_method'])
		{
		  if (typeof data == 'string')
		    data += '&_method=DELETE';
		  else
		    data['_method'] = 'DELETE';
		}

		return jQuery.ajax({
			type: "POST",
			url: url,
			data: data,
			success: callback,
			dataType: type
		});
	},
	
	put: function( url, data, callback, type ) {
		if ( jQuery.isFunction( data ) ) {
			callback = data;
			data = {};
		}
		
		data = data == null ? {} : data;
		if (!data['_method'])
		{
		  if (typeof data == 'string')
		    data += '&_method=PUT';
		  else
		    data['_method'] = 'PUT';
		}
		
		return jQuery.ajax({
			type: "POST",
			url: url,
			data: data,
			success: callback,
			dataType: type
		});
	}
});

// authenticity_token fix

$(document).ajaxSend(function(event, request, settings) {
  if (typeof(AUTH_TOKEN) == "undefined" || request.type == 'GET') return;
  settings.data = settings.data ? (settings.data + '&') : "";
  settings.data += "authenticity_token=" + encodeURIComponent(AUTH_TOKEN);
});

// Main entrypoint

$(document).ready(function(){
    if (!PAGE_READONLY) {
      InsertionMarker.init();
      InsertionBar.init();
    }
    
    HoverHandle.init();
    
    Page.makeSortable();
    
    $('#content').mousemove(PageHoverHandlerFunc);
    $('#content').mouseout(PageHoverHandlerCancelFunc);
    
    $('#outerWrapper').mousemove(InsertionMarkerFunc);
    
    Page.bindStatic();
    Page.bind();
    
    $('#pageResizeHandle').mousedown(Page.startResize);
});

// Handles the hover bar for modifying widgets 
var HoverHandle = {
    enabled: false,
    
    init: function() {
        this.current_handle = null;
        this.enabled = true;
    },
    
    setEnabled: function(val) {
        this.enabled = val;
    },
    
    setHandle: function(handle) {
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
        if (InsertionMarker.enabled)
        {
            InsertionMarker.setEnabled(false);
            InsertionMarker.hide();
        }
        
        this.current_handle = handle;
    },
    
    clearHandle: function() {
        if (!this.current_handle)
            return;
            
        if (!this.enabled)
        {
            this.current_handle.hide();
            return;
        }
        
        // Make sure the old one vanishes
        if (!this.current_handle.is(':animated'))
           this.current_handle.fadeOut(800, function() { this.current_handle = null; });
        if (!InsertionMarker.enabled)
            InsertionMarker.setEnabled(true);
    }
};

// Insertion bar which appears between slots
var InsertionBar = {
    element: null,
    element_bar: null,
    element_tablet: null,
    current_form: null,
    
    init: function() {
        this.element = $('#pageInsertItems');
        this.element_bar  = $('#pageInsertItemsBar');
        this.element_tablet = $('#pageTabletContainer');
    },
    show: function() {
        InsertionMarker.element.before(this.element);
        this.element_bar.css('height', '0px').show().animate({"height": "25px"}, "fast");
    },
    hide: function() {
        this.element_bar.hide();
    },
    
    magicForm: function(el) {
        // Reveal form using an expanding blind effect
        var calc_height = el.height();
        var init = true;
        el.css({'height': '42px', 'overflow': 'hidden'}).animate(
          {'height': calc_height + 'px'}, 
          {'duration': "fast",
           'step': function(evt) {
             // Hack - this needs to be set after, otherwise headers vanish
             if (init) {
               el.css('overflow', 'hidden');
               init = false;
             }
           },
           'complete': function(evt){
              // Defaults
              el.css('height', null).css('overflow', 'visible');
            }
          } 
        );

    },
    
    // Widget form
    setWidgetForm: function(template) {
        if (this.current_form)
            this.clearWidgetForm();
        
        // Set insertion position
        var id = template.attr('id');
        $('#' + id + 'Before').attr('value', Page.insert_before ? '1' : '0');
        $('#' + id + 'Slot').attr('value', Page.insert_element.attr('slot'));
        
        // Form should go in the insertion bar, so we can change the insertion location and maintain
        // state
        this.element_tablet.append(template);
        this.magicForm($('#' + id));
        this.current_form = template;
    },
    
    clearWidgetForm: function() {
        if (!this.current_form)
          return;
        
        this.current_form.children('form').reset();
        $('#pageWidgetForms').append(this.current_form);
        this.current_form = null;
    }
};

// Insertion marker which appears between slots
var InsertionMarker = {
    element: null,
    enabled: false,
    visible: false,
    
    init: function() {
        this.element = $('#pageInsert');
        this.enabled = true;
        this.visible = false;
    },
    setEnabled: function(val) {
        this.enabled = val;
    },
    show: function(el, insert_before) {
        this.visible = true;
        this.set(el, insert_before);
        this.element.show();
    },
    hide: function() {
        if (this.visible) {
            this.element.hide();
            this.visible = false;
            if (this.enabled)
                this.set(null, true);
        }
    },
    set: function(element, insert_before) {
        var el = element ? element : $('#slots').children('.pageSlot:first');
        
        Page.insert_element = el;
        Page.insert_before = insert_before;
        
        if (insert_before)
          el.before(this.element);
        else
          el.after(this.element);
    }
}

// Main page controller
var Page = {
    MARGIN: 20,
    SLOT_VERGE: 20,
    
    JOURNAL_OFFSET: 50,
    
    isResizing: false,
    lastResizePosition: 0,
    
    isSortingWrappedElements: false,
    
    init: function() {
      Insertion.set(null);
    },
    
    endJournalEntries: function() {
      $("#userJournalsMore").remove();
    },
    
    stopSortingWrappedElements: function(item) {
      // Need to re-incorporate the elements
      var elements_after = item.children(":last").children();
      
      for (var i=elements_after.length-1; i >= 0; i--) {
        $(elements_after[i]).insertAfter(item);
      }
      Page.isSortingWrappedElements = false;
    },
    
    startResize: function(e) {
      var evt = e.originalEvent;
      Page.lastResizePosition = evt.clientX;
      Page.isResizing = true;
      
      InsertionMarker.setEnabled(false);
      HoverHandle.setEnabled(false);
      
      var content = $('#innerWrapper');
      content.css('margin', '0px 0px 0px ' + content.offset().left + 'px');
      
      $('#body').css('cursor', 'move').disableTextSelect();
      $(document).mousemove(Page.doResize).mouseup(Page.endResize);
    },
    
    endResize: function(e) {
      Page.isResizing = false;
      
      InsertionMarker.setEnabled(true);
      HoverHandle.setEnabled(true);
      
      $('#body').css('cursor', 'default').enableTextSelect();
      
      var content = $('#innerWrapper');
      content.css('margin', '0px auto');
      
      $(document).unbind('mouseup', Page.endResize);
      $(document).unbind('mousemove', Page.doResize);
      
      $.put(Page.buildUrl('/resize'), {'page[width]': PAGE_WIDTH}, null, 'script');
    },
    
    doResize: function(e) {
      if (!Page.isResizing)
        return false;
      
      var evt = e.originalEvent;
      var delta = evt.clientX - Page.lastResizePosition;
      Page.setWidth(PAGE_WIDTH + delta);
      
      Page.lastResizePosition = evt.clientX;
    },
    
    setWidth: function(width) {
      PAGE_WIDTH = width;
      $('#content').css('width', PAGE_WIDTH + 'px');
      $('#innerWrapper').css('width', (PAGE_WIDTH + 200) + 'px');
    },
    
    buildUrl: function(resource_url) {
      if (PAGE_ID != null)
        return '/pages/' + PAGE_ID + resource_url;
      else
        return resource_url;
    },
    
    //
    // Core re-bindable actions
    //
    
    onHeaderSubmit: function(evt) {
        $(this).request(JustRebind, 'script');

      return false;
    },

    onHeaderCancel: function(evt) {
      $('#page_header_form').hide();
      $('#page_header').show();
      
      return false;
    },

    onWidgetFormSubmit: function(evt) {
      var el = $(this);
      if (el.hasClass('upload')) {
        el.requestIframeScript({}, JustRebind);
        return true;
      }
      else
        el.request(JustRebind, 'script');
      
      // Loader
      el.find('.submit:first').attr('disabled', true).html(Page.loader());
  
      return false;
    },

    onWidgetFormCancel: function(evt) {
      var form = $(evt.target).parents('form:first');
      
      $.get(form.attr('action'), {}, JustRebind, 'script');
      
      return false;
    },

    onFixedWidgetFormSubmit: function(evt) {
      var el = $(this);
      var submit_button = el.find('.submit:first');
      
      // Loader
      var old_submit = submit_button.html();
      submit_button.attr('disabled', true).html(Page.loader());
      
      // Note: closures used here so that submit button can be reset
      if (el.hasClass('upload')) {
        el.requestIframeScript({'is_new': 1}, function(data) { submit_button.attr('disabled', false).html(old_submit); ResetAndRebind(data); });
        return true;
      }
      else
        el.request(function(data) { submit_button.attr('disabled', false).html(old_submit); ResetAndRebind(data); }, 'script');
      
      return false;
    },

    onFixedWidgetFormCancel: function(evt) {
      InsertionBar.clearWidgetForm();
      
      return false;
    },
    
    onAddItemSubmit: function(evt) {
      var form = $(this);
      form.request(JustRebind, 'script')
      form.reset();
      return false;
    },
      
    onAddItemCancel: function(evt) {
      var addItemInner = $(evt.target).parents('.inner:first');
      var newItem = addItemInner.parents('.addItem:first').find('.newItem:first');
      
      addItemInner.hide();
      addItemInner.children('form').reset();
      newItem.show();
      
      return false;
    },
    
    onAddItemLink: function(evt) {
      var newItem = $(evt.target.parentNode);
      var addItemInner = newItem.parents('.addItem:first').find('.inner:first');
      
      addItemInner.show();
      addItemInner.autofocus();
      newItem.hide();
      
      return false;
    },
      
    onListSubmit: function(evt) {
      $(this).request(JustRebind, 'script');
      
      return false;
    },
    
    onListCancel: function(evt) {
      var el = $(evt.target);
      var list_url = el.parents('.pageWidget:first').attr('url');
      var item_id = el.parents('.listItem:first').attr('item_id');
      
      $.get(Page.buildUrl(list_url + '/items/' + item_id), null, JustRebind, 'script');
      
      return false;
    },
      
    onListItemCheck: function(evt) {
      var el = $(evt.target);
      var list_url = el.parents('.pageWidget:first').attr('url');
      var item_id = el.parents('.listItem:first').attr('item_id');
      
      // Loader gif
      el.siblings('.itemText').html(Page.loader());
      
      $.put(Page.buildUrl(list_url + '/items/' + item_id + '/status'), {'list_item[completed]':evt.target.checked}, JustRebind, 'script');
      
      return false;
    },
      
    onListItemDelete: function(evt) {
      var el = $(evt.target);
      var list_url = el.parents('.pageWidget:first').attr('url');
      var item_id = el.parents('.listItem:first').attr('item_id');
      
      $.del(Page.buildUrl(list_url + '/items/' + item_id), null, JustRebind, 'script');
      
      return false;
    },
      
    onListItemShowMore: function(evt) {
      var el = $(evt.target);
      var list_url = el.parents('.pageWidget:first').attr('url');
      
      el.parent().hide();
      $.get(Page.buildUrl(list_url + '/items'), {'completed':1, 'limit':-1, 'offset': 5}, JustRebind, 'script');
      
      return false;
    },  
      
    onListItemSubmit: function(evt) {
      $(this).request(JustRebind, 'script');
      
      return false;
    },
    
    onListItemCancel: function(evt) {
      var el = $(evt.target);
      var pageList = el.parents('.pageList:first');
      
      pageList.find('.pageListForm:first').hide();
      pageList.find('.pageListHeader:first').show();
      
      return false;
    },
    
    onAlbumSubmit: function(evt) {
      var el = $(this);
      el.request(JustRebind, 'script');  
  
      return false;
    },

    onAlbumCancel: function(evt) {
      var el = $(evt.target);
      var pageAlbum = el.parents('.pageAlbum:first');
      
      pageAlbum.find('.pageAlbumForm:first').hide();
      pageAlbum.find('.pageAlbumHeader:first').show();
      
      return false;
    },

    onAddAlbumPicture: function(evt) {
      var newPicture = $(evt.target.parentNode);
      var addPictureInner = newPicture.parents('.albumPictureForm:first').find('.inner:first');
      
      addPictureInner.show();
      addPictureInner.autofocus();
      newPicture.hide();
      
      return false;
    },

    onAlbumPictureSubmit: function(evt) {
      var el = $(this);
      el.requestIframeScript({}, JustRebind);
      return true;
    },

    onAlbumPictureCancel: function(evt) {
      var el = $(this);
      $.get(el.parents('form:first').attr('action'), null, JustRebind, 'script');
      return false;
    },
      
    onNewAlbumPictureSubmit: function(evt) {
      var el = $(this);
      el.requestIframeScript({'is_new': 1, 'el_id': $(this).parents(".albumPictureForm:first").attr("id")}, JustRebind);
      return true;
    },
      
    onNewAlbumPictureCancel: function(evt) {
      var newPictureInner = $(evt.target).parents('.inner:first');
      var newPicture = newPictureInner.parents('.albumPictureForm:first:first').find('.newPicture:first');
      
      newPictureInner.hide();
      newPictureInner.children('form').reset();
      newPicture.show();
      
      return false;
    },
    
    onEditTags: function(evt) {
      $(this).request(JustRebind, 'script');
             
      return false;
    },
    
    onEditTagsCancel: function(evt) {
      $('#pageTagsForm').hide();
      $('#pageTags').show();
      $('#pageEditTags').show();
      
      return false;
    },  
      
    onTagAdd: function(evt) {
      TAG_LIST.push($(evt.target).attr('tag'));
      
      $.get('/pages', {'tags[]': TAG_LIST}, JustRebind, 'script');
      return false;
    },
    
    onTagRemove: function(evt) {
      var removed_tag = $(evt.target).attr('tag');
      
      TAG_LIST = $.grep(TAG_LIST, function(tag){
        return (tag != removed_tag);
      });
      
      $.get('/pages', {'tags[]': TAG_LIST}, JustRebind, 'script');
      return false;
    },
    
    onReminderSnooze: function(evt) {
      var el = $(evt.target);
      var reminder_url = el.parents('.reminderEntry:first').attr('url') + '/snooze';
      $.put(reminder_url, {}, JustRebind, 'script');
      
      return false;
    },
      
    onReminderDelete: function(evt) {
      var el = $(evt.target);
      var reminder_url = el.parents('.reminderEntry:first').attr('url');
      
      $.del(reminder_url, {}, JustRebind, 'script');
      
      return false;
    },
    
    onReminderSubmit: function(evt) {
      $(this).request(RebindAndHover, 'script');
             
      return false;
    },
      
    onReminderCancel: function(evt) {
      $.get('/reminders', {}, JustRebind, 'script');
      
      HoverHandle.setEnabled(true);
      
      return false;
    },
      
    // User list
    onUserDelete: function(evt) {
      var el = $(this);
      
      var user_id = el.parents('tr:first').attr('user_id');
      
      // TODO: need localization
      if (confirm('Are you sure you want to delete this user?'))
        $.del('/users/' + user_id, {}, JustRebind, 'script');
      
      return false;
    },
    
    bind: function() {
      // Page header
      $('#page_header_form form').submit(Page.onHeaderSubmit);
      $('#page_header_form .cancel').click(Page.onHeaderCancel);
      
      $('.pageSlotHandle').click(HoverSlotBar);

      $('.widgetForm').submit(Page.onWidgetFormSubmit);
      $('.widgetForm .cancel').click(Page.onWidgetFormCancel);

      $('.fixedWidgetForm').submit(Page.onFixedWidgetFormSubmit);
      $('.fixedWidgetForm .cancel').click(Page.onFixedWidgetFormCancel);
      
      // Popup form for Add Item
      $('.addItem form').submit(Page.onAddItemSubmit);
      $('.addItem form .cancel').click(Page.onAddItemCancel);
      
      // Add Item link
      $('.newItem a').click(Page.onAddItemLink);
      $('.listItem form').submit(Page.onListSubmit);
      $('.listItem form .cancel').click(Page.onListCancel);
      
      $('.pageList .checkbox').click(Page.onListItemCheck);
      $('.pageList .itemDelete').click(Page.onListItemDelete);
      
      $('.pageList .showItems a').click(Page.onListItemShowMore);
      
      $('.pageListForm form').submit(Page.onListItemSubmit);
      $('.pageListForm form .cancel').click(Page.onListItemCancel);
      
      // Page album
      $('.pageAlbumForm').submit(Page.onAlbumSubmit);
      $('.pageAlbumForm .cancel').click(Page.onAlbumCancel);

      $('.newPicture a').click(Page.onAddAlbumPicture);
      
      // Edit picture form
      $('.albumPicture form').submit(Page.onAlbumPictureSubmit);
      $('.albumPicture form .cancel').click(Page.onAlbumPictureCancel);
      
      // New picture form
      $('.albumPictureForm form').submit(Page.onNewAlbumPictureSubmit);
      $('.albumPictureForm form .cancel').click(Page.onNewAlbumPictureCancel);
      
      // Page list tags
      $('#pageTagsForm form').submit(Page.onEditTags);
      $('#pageTagsForm .cancel').click(Page.onEditTagsCancel);  
      
      // + -
      $('.pageTagAdd').click(Page.onTagAdd);
      $('.pageTagRemove').click(Page.onTagRemove); 
      
      // Reminder page
      
      $('.reminderSnooze').click(Page.onReminderSnooze);
      $('.reminderDelete').click(Page.onReminderDelete);
      $('.reminderForm').submit(Page.onReminderSubmit);
      $('.reminderForm .cancel').click(Page.onReminderCancel);
      
      // User list
      $('#userList .userDelete').click(Page.onUserDelete);
    
    
    },
    
    bindStatic: function() {

      // Insert widgets
      $('.add_List').click(function(evt) {
        // Set to top of page if on top toolbar
        if ($(this).hasClass('atTop'))
          InsertionMarker.set(null, true);

        Page.insertWidget('lists');
        InsertionBar.hide();
        InsertionMarker.setEnabled(true);
        HoverHandle.setEnabled(true);
          
        return false;
      });

      $('.add_Note').click(function(evt) {
        // Set to top of page if on top toolbar
        if ($(this).hasClass('atTop'))
          InsertionMarker.set(null, true);
        
        var form = $('#add_NoteForm');
  
        InsertionBar.setWidgetForm(form);
        InsertionBar.hide();
        InsertionMarker.setEnabled(true);
        HoverHandle.setEnabled(true);
        
        form.autofocus();
  
        return false;
      });

      $('.add_Separator').click(function(evt) {
        // Set to top of page if on top toolbar
        if ($(this).hasClass('atTop'))
          InsertionMarker.set(null, true);
        
        var form = $('#add_SeparatorForm');
  
        InsertionBar.setWidgetForm(form);
        InsertionBar.hide();
        InsertionMarker.setEnabled(true);
        HoverHandle.setEnabled(true);
        
        form.autofocus();
  
        return false;
      });

      $('.add_UploadedFile').click(function(evt) {
        // Set to top of page if on top toolbar
        if ($(this).hasClass('atTop'))
          InsertionMarker.set(null, true);
        
        var form = $('#add_UploadedFileForm');
  
        InsertionBar.setWidgetForm(form);
        InsertionBar.hide();
        InsertionMarker.setEnabled(true);
        HoverHandle.setEnabled(true);
        
        form.autofocus();
  
        return false;
      });

      $('.add_Album').click(function(evt) {
        // Set to top of page if on top toolbar
        if ($(this).hasClass('atTop'))
          InsertionMarker.set(null, true);
        
        var form = $('#add_AlbumForm');
  
        InsertionBar.setWidgetForm(form);
        InsertionBar.hide();
        InsertionMarker.setEnabled(true);
        HoverHandle.setEnabled(true);
        
        form.autofocus();
  
        return false;
      });
      
      // Page
      
      $('#pageInsert').click(function(evt) {
        InsertionBar.show();
        //console.log('IM SET');
        InsertionMarker.setEnabled(false);
        InsertionMarker.hide();
        //console.log('IM DONE');
        HoverHandle.setEnabled(false);
        HoverHandle.clearHandle();
        
        return false;
      });
      
      $('#pageInsertItemCancel a').click(function(evt) {
        InsertionBar.hide();
        InsertionMarker.setEnabled(true);
        HoverHandle.setEnabled(true);
        
        return false;
      });
      
      $('#pageSetFavourite').click(function(evt) {
        $.put(Page.buildUrl('/favourite'), {'page[is_favourite]': '1'}, null, 'script');
        return false;
      });
      
      $('#pageSetNotFavourite').click(function(evt) {
        $.put(Page.buildUrl('/favourite'), {'page[is_favourite]': '0'}, null, 'script');
        return false;
      });
      
      $('#pageDuplicate').click(function(evt) {
        $.post(Page.buildUrl('/duplicate'), {'foo':1}, null, 'script');
        return false;
      });
      
      $('#pageDelete').click(function(evt) {
        if (confirm("Are you sure you want to delete this page?"))
          $.del(Page.buildUrl(''), {}, null, 'script');
        return false;
      });
      
      $('#pageAddress').click(function(evt) {
        if (evt.target.id == 'pageReset') {
          $.put(Page.buildUrl('/reset_address'), {}, null, 'script');
          return false;
        }
        
        return true;
      });
         
      // Page list tags
      $('#pageEditTags .edit').click(function(evt) {
        $.get(Page.buildUrl('/tags'), {}, JustRebind, 'script');
        return false;
      });
      
      // Reminder page
      
      $('#add_ReminderForm').submit(function(evt) {
        $(this).request(JustRebind, 'script');
        
        return false;
      });
      
      // Journal
      $('#edit_UserStatus').submit(function(evt) {
        $(this).request(JustRebind, 'script');
        
        return false;
      });
      
      $('#edit_UserStatus .cancel').click(function(evt) {
        
        $('#user_status_form').hide();
        $('#user_status').show();
        
        return false;
      });
    
      $('#user_status').click(function(evt) {
        if (this.tagName == 'A')
          return true;
        
        $('#user_status').hide();
        $('#user_status_form').show();
        
        return false;
      });
    
      $('#userJournal form').submit(function(evt) {
        var el = $(this);
        
        el.request(JustRebind, 'script');
            
        el.reset();
       
        return false;
      });
      
      $('#statusBar').click(function(evt) {
        $(this).hide('slow');
        
        return false;
      });
      
      // Journal
      $('#userJournalsMore a').click(function(evt) {
        $.get("/journals", {'offset': Page.JOURNAL_OFFSET}, ResetAndRebind, 'script');
        
        Page.JOURNAL_OFFSET += 50;
        
        return false;
      });
      
      // Page sidebar
      $('.addPageLink a').click(function(evt) {
        var newPage = $(evt.target.parentNode);
        var addPageInner = newPage.parents('.addPage:first').find('.inner:first');
        
        addPageInner.show();
        addPageInner.autofocus();
		newPage.hide();
        
        return false;
      });
      
      $('.addPage form').submit(function(evt) {
        var el = $(this);
		var submit_button = el.find('.submit:first');
        var root = el.parents('.addPage:first');
        var newPage = root.find('.addPageLink:first');
        var addPageInner = root.find('.inner:first');
        
        // Loader
        var old_submit = submit_button.html();
        submit_button.attr('disabled', true).html(Page.loader());
        
        $(this).request(function(data){
          addPageInner.hide(); 
          newPage.show();
          submit_button.attr('disabled', false).html(old_submit);
          ResetAndRebind(data);
        }, 'script');
                
        return false;
      });
    
      $('.addPage form .cancel').click(function(evt) {
        var root = $(evt.target.parentNode).parents('.addPage:first');
        var newPage = root.find('.addPageLink:first');
        var addPageInner = root.find('.inner:first');
        
        addPageInner.hide();
        newPage.show();
        
        return false;
      });
      
      // Login
      
      $('.toggleOpenID').click(function(evt) {
        var field = $('#loginOpenID');
        if (field.attr('value') == '1') {
          field.attr('value', '0');
          $('#openid_login').hide();
          $('#normal_login').show();
        } else {
          field.attr('value', '1');
          $('#normal_login').hide();
          $('#openid_login').show();
        }
        
        return false;
      });
    
    },
    
    rebind: function () {
      $('.pageSlotHandle').unbind();
      $('.widgetForm').unbind();
      $('.widgetForm .cancel').unbind();
      $('.fixedWidgetForm').unbind();
      $('.fixedWidgetForm .cancel').unbind();
            
      $('.addItem form').unbind();
      $('.addItem form .cancel').unbind();
      $('.newItem a').unbind();
      
      $('.listItem form').unbind();
      $('.listItem form .cancel').unbind();
      
      $('.pageList .checkbox').unbind();
      $('.pageList .itemDelete').unbind();
      $('.pageList .showItems a').unbind();
      
      $('.pageListForm form').unbind();
      $('.pageListForm form .cancel').unbind();

      $('.newPicture a').unbind();
      $('.albumPicture form').unbind();
      $('.albumPicture form .cancel').unbind(); 
      $('.albumPictureForm form').unbind();
      $('.albumPictureForm form .cancel').unbind();    
      $('.pageAlbumForm').unbind();
      $('.pageAlbumForm .cancel').unbind();

      $('.pageTagAdd').unbind();
      $('.pageTagRemove').unbind();
      
      $('.reminderSnooze').unbind();
      $('.reminderDelete').unbind();
      
      Page.bind();
    },
    
    setFavourite: function(favourite) {
        if (favourite)
        {
            $('#pageSetFavourite').hide();
            $('#pageSetNotFavourite').show();
        }
        else
        {
            $('#pageSetNotFavourite').hide();
            $('#pageSetFavourite').show();
        }
    },
    
    loader: function() {
      return "<img src=\"/images/icons/loading.gif\"/>";
    },
    
    insertWidget: function(resource) {
        if (PAGE_READONLY)
            return;
        
        // Insert
        $.post('/pages/' + PAGE_ID + '/' + resource, 
              {'position[slot]': this.insert_element.attr('slot') , 
               'position[before]': (this.insert_before ? '1' : '0')}, ResetAndRebind, 'script');
    },
    
    dropSlotFunction : function(ev, ui) {
      // Add all of the wrapped elements
      if (Page.isSortingWrappedElements) {
        var page_id = $(this).attr('page_id');
        ui.draggable.children(":last").children().each(function() {
          Page.moveSlotTo($(this).attr('slot'), page_id);
        });
      }
      Page.moveSlotTo(ui.draggable.attr('slot'), $(this).attr('page_id'));
    },
    
    makeSortable: function() {
		if (PAGE_READONLY)
            return;
        
        var lists = $('.pageList .openItems .listItems');
        
        lists.each(function(i) {
          Page.makeListSortable($(this));
        });
        
        // Refresh so we can drag between
        lists.each(function(i) {
          $(this).sortable('refresh');
        });
        
        // Add droppables
		$('#stdPageListItems li').each(function(i)
		{
			var el = $(this);
			if (!el.hasClass('current'))
			{
				el.droppable('destroy');
				el.droppable({ hoverClass:'hover', accept:'.pageSlot', tolerance: 'pointer', drop:Page.dropSlotFunction});
			}
		});
		
		$('#usrPageListItems li').each(function(i)
		{
			var el = $(this);
			if (!el.hasClass('current'))
			{
				el.droppable('destroy');
				el.droppable({ hoverClass:'hover', accept:'.pageSlot', tolerance: 'pointer', drop:Page.dropSlotFunction});
			}
		});
		
		// Make sidebar sortable
		$('#usrPageListItems').sortable('destroy');
		$('#usrPageListItems').sortable({
			axis: 'y',
			handle: '.usr_page_handle',
			items: '> .sidebar_page',
			opacity: 0.75,
			update: function(e, ui)
			{
				$.post('/pages/reorder_sidebar', $('#usrPageListItems').sortable('serialize', {key: 'page_ids'}));
			}
		});
		
       $('#slots').sortable('destroy');
       $('#slots').sortable({
         axis: 'y',
         handle: '.slot_handle',
         items: '> .pageSlot',
         opacity: 0.75,
         start: function(e, ui) {
           // Press alt to move everything under separator
           if (e.originalEvent.altKey) {
             var separator_index = $("#slots > *").index(ui.item[0]);
             var elements_after = ui.helper.siblings(":gt(" + separator_index + ")");
             
             var found_end = false;
             
             var elements_after = elements_after.filter(function() {
               if (found_end)
                 return false;
                
               if ($(this).find(".pageWidget .pageSeparator").length == 1)
               {
                 found_end = true;
                 return false;
               }
              
               return true;
             });
             
             // Skip if no extra elements are being sorted
             if (elements_after.length == 0)
               return;
             
             ui.item.append("<div class=\"sortableGroup\"></div>");
             ui.item.children(":last").append(elements_after);
             ui.helper.append(elements_after.clone());
             
             Page.isSortingWrappedElements = true;
           }
         },
         stop: function(e, ui) {
           if (Page.isSortingWrappedElements)
             Page.stopSortingWrappedElements(ui.item);
         },
         update: function(e, ui) {
           if (Page.isSortingWrappedElements)
             Page.stopSortingWrappedElements(ui.item);
           $.post('/pages/' + PAGE_ID + '/reorder', $('#slots').sortable('serialize', {key: 'slots'}));
         }
       });                           
    },
    
    moveSlotTo: function(slot_id, page_id) {
        $.put('/pages/' + page_id + '/' + 'transfer', {'page_slot[id]': slot_id }, null, 'script');
    },
    
    makeListSortable: function(el) {
        var list_url = el.parents('.pageWidget:first').attr('url');
        
        el.sortable('destroy');
        el.sortable({
          axis: 'y',
          handle: '.slot_handle',
          connectWith: ['.pageList .openItems .listItems'],
          opacity: 0.75,
          update: function(e, ui) {
            // Check for item movement vs item update. Note that the 
            // list the item is moved to will do its own update after.
            
            var list = ui.item.parent('.listItems');
            if (list.attr('id') !=
                ui.element.attr('id'))
              $.put('/pages/' + PAGE_ID + list.parents('.pageWidget:first').attr('url') + '/transfer', {'list_item[id]': ui.item.attr('item_id')});
            else
              $.post('/pages/' + PAGE_ID + list_url + '/reorder', el.sortable('serialize', {key: 'items'}));
          }
        }); 
    }
}


// Event handlers


// Hover observer for HoverHandle
var PageHoverHandlerFunc = function(evt){
    if (!HoverHandle.enabled)
        return;
    
    var el = $(evt.target);
    
    var hover = null;
    var handler = el.attr('hover_handle');
    if (handler)
        hover = $('#' + handler);
    else if (el.hasClass('innerHandle'))
        hover = el.parents('.pageSlotHandle:first');
    
    if (hover)
        HoverHandle.setHandle(hover);
    else
        HoverHandle.clearHandle();
};

var PageHoverHandlerCancelFunc = function(evt){
    HoverHandle.clearHandle();
};

// Hover observer for InsertionMarker
var InsertionMarkerFunc = function(evt){    
    if (!InsertionMarker.enabled)
        return;
    
    var el = $(evt.target);
    var pt = [evt.clientX, evt.clientY];
    pt.x = pt[0]; pt.y = pt[1];
    var offset = el.offset();
    
    if (!(pt.x - offset.left > Page.MARGIN))
    {
        if (el.hasClass('pageSlot'))
        {
            var h = el.height(), thr = Math.min(h / 2, Page.SLOT_VERGE);
            var t = offset.top, b = t + h;
        
            if (el.hasClass('pageFooter')) // before footer
                InsertionMarker.show(el, true);
            else if (pt.y - t <= thr) // before element
                InsertionMarker.show(el, true);
            else if (b - pt.y <= thr) // after element
                InsertionMarker.show(el, false);
            else
               InsertionMarker.hide(); // *poof*           
        }
    }
    else
    {
        // Handle offset when hovering over insert bar
        if (el.attr('id') == "cpi") 
        {
            if (!(pt.x - offset.left > (90+Page.MARGIN)))
                return;
        }
        
        InsertionMarker.hide(); // *poof*
    }
};

function JustRebind(data) {
  Page.rebind();
}

function RebindAndHover(data) {
  Page.rebind();
  HoverHandle.setEnabled(true);
}

function ResetAndRebind(data) {
  // Clean up state
  InsertionBar.hide();
  InsertionBar.clearWidgetForm();
  
  Page.rebind();
}

// Hover bar which appears when hovering over widgets

function HoverSlotBar(evt) {
  var el = $(evt.target);
  var cur = $(this);
  
  var url = cur.parents(cur.attr('restype') + ':first').attr('url');
  
  if (el.hasClass('slot_delete') && confirm("Are you sure you want to delete this item?"))
    $.del(Page.buildUrl(url), null, JustRebind, 'script');
  else if (el.hasClass('slot_edit'))
    $.get(Page.buildUrl(url + '/edit'), null, JustRebind, 'script');
  else
    return false;
  
  return true;
}
