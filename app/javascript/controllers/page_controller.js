import { Controller } from "@hotwired/stimulus";
import { Draggable, Droppable, Sortable } from "@shopify/draggable";
import $ from "cash-dom";

import RucksackHelpers from "helpers/rucksack_helpers";
import HoverHandle from "helpers/hover_handle";
import InsertionBar from "helpers/insertion_bar";
import InsertionMarker from "helpers/insertion_marker";

// Main page controller
export default class extends Controller
{
  init() {
    this.MARGIN = 20;
    this.SLOT_VERGE = 20;

    this.isResizing = false;
    this.lastResizePosition = 0;

    this.isSortingWrappedElements = false;
    this.TAG_LIST = [];
    this.ID = null;
    this.TYPE = null;
    this.READONLY = true;

    this.insertionMarker = new InsertionMarker(this);
    this.insertionBar = new InsertionBar(this);
    this.hoverHandle = new HoverHandle(this);

    this.staticBoundEvents = [];
    this.dynamicBoundEvents = [];
  }

  connect() {
    window.Page = this;

    console.log('Connecting page controller....', this.element);
    this.init();

    $('#content').on('mousemove', this.PageHoverHandlerFunc);
    $('#content').on('mouseout', this.PageHoverHandlerCancelFunc);
    $('#outerWrapper').on('mousemove', this.InsertionMarkerFunc);
    $('#pageResizeHandle').on('mousedown', this.startResize);

    this.bindStatic();
    this.bind();

    this.TYPE = this.lookupMeta('page-type', null);
    this.ID = this.lookupMeta('page-id', null);
    this.READONLY = this.lookupMeta('page-readonly', false);
    this.WIDTH = parseInt(this.lookupMeta('page-width', '400'));

    if (this.TYPE == 'page')
    {
      if (!this.READONLY)
      {
        this.insertionMarker.init();
        this.insertionBar.init();
        this.insertionMarker.set(null);
      }
    }
    else if (this.TYPE == 'pages')
    {
        //this.TAG_LIST = $('#tagNewCrumbs .tagCrumb span.pageTagAdd').map(function(){
        //  return $(this).attr('tag');
        //});
    }

    this.hoverHandle.init();
    this.makeSortable();
  }

  lookupMeta(key, def) {
    var meta = $('meta[name="' + key + '"]');
    return meta.length > 0 ? meta.attr('content') : def;
  }

  updateTags() {
    if (this.TAG_LIST.length == 0)
    {
      $('#pageTable .pageEntry').show();
      return;
    }

    $('#pageTable .pageEntry').each(function(){
      var el = $(this);
      var tags = el.attr('tags').split(',');
      var i=0;

      // NOTE: tags must have all this.PAGE_LIST tags!
      for (i=0; i<this.TAG_LIST.length ;i++) {
        if (tags.indexOf(this.TAG_LIST[i]) < 0)
          break;
      }

      if (i >= this.TAG_LIST.length)
      {
        el.show();
      }
      else
      {
        el.hide();
      }
    });
  }

  disconnect() {
    this.clearDynamicEvents();
    this.clearStaticEvents();

    window.Page = null;

    $('#content').off('mousemove', this.PageHoverHandlerFunc);
    $('#content').off('mouseout', this.PageHoverHandlerCancelFunc);
    $('#outerWrapper').off('mousemove', this.InsertionMarkerFunc);
    $('#pageResizeHandle').off('mousedown', this.startResize);
  }

  bumpJournalEntries(last_id) {
    $('#userJournalsMore').attr('from', last_id);
  }

  insertJournalEntries(header, content, before) {
    if (before)
    {
      var existing_header = $($('#userJournals h2')[0]);
      if (existing_header.html() == header)
        existing_header.remove();

      $('#userJournals').prepend(content);
    }
    else
    {
      $('#userJournals').append(content);
    }
  }

  endJournalEntries() {
    $("#userJournalsMore").remove();
  }

  stopSortingWrappedElements(item) {
    // Need to re-incorporate the elements
    var elements_after = item.children(":last").children();

    for (var i=elements_after.length-1; i >= 0; i--) {
      $(elements_after[i]).insertAfter(item);
    }

    this.isSortingWrappedElements = false;
  }

  startResize(e) {
    var evt = e.originalEvent;
    this.lastResizePosition = evt.clientX;
    this.isResizing = true;

    this.insertionMarker.setEnabled(false);
    this.hoverHandle.setEnabled(false);

    var content = $('#innerWrapper');
    content.css('margin', '0px 0px 0px ' + content.offset().left + 'px');

    $(this.element).on('mouseup', this.endResize);
    $(this.element).on('mousemove', this.doResize);
  }

  endResize(e) {
    this.isResizing = false;

    this.insertionMarker.setEnabled(true);
    this.hoverHandle.setEnabled(true);

    var content = $('#innerWrapper');
    content.css('margin', '0px auto');

    $(this.element).off('mouseup', this.endResize);
    $(this.element).off('mousemove', this.doResize);

    RucksackHelpers.put(this.buildUrl('/resize'), {'page[width]': this.WIDTH}, null);
  }

  doResize(e) {
    if (!this.isResizing)
      return false;

    var evt = e.originalEvent;
    var delta = evt.clientX - this.lastResizePosition;
    this.setWidth(this.WIDTH + delta);

    this.lastResizePosition = evt.clientX;
  }

  setWidth(width) {
    this.WIDTH = width;
    $('#content').css('width', this.WIDTH + 'px');
    $('#innerWrapper').css('width', (this.WIDTH + 200) + 'px');
  }

  buildUrl(resource_url) {
    if (this.ID != null)
      return '/pages/' + this.ID + resource_url;
    else
      return resource_url;
  }

    //
    // Core re-bindable actions
    //

  onHeaderSubmit(evt) {

      //await fetch(`/search?query=${query}`);
    RucksackHelpers.request($(this), this.bind(this.JustRebind));

    return false;
  }

  onHeaderCancel(evt) {
    $('#page_header_form').hide();
    $('#page_header').show();

    return false;
  }

  onWidgetFormSubmit(evt) {
    var el = $(this);
    if (el.hasClass('upload')) {
      RucksackHelpers.requestIframeScript(el, {}, this.bind(this.JustRebind));
      return true;
    }
    else
    {
      RucksackHelpers.request(el, this.bind(this.JustRebind));
    }

      // Loader
    el.find('.submit:first').attr('disabled', true).html(this.loader());

    return false;
  }

  onWidgetFormCancel(evt) {
    var form = $(evt.target).parents('form:first');

    RucksackHelpers.get(form.attr('action'), {}, this.bind(this.JustRebind));

    return false;
  }

  onFixedWidgetFormSubmit(evt) {
    var el = $(this);
    var submit_button = el.find('.submit:first');
    var pageController = this;

      // Loader
    var old_submit = submit_button.html();
    submit_button.attr('disabled', true).html(this.loader());

      // Note: closures used here so that submit button can be reset
    if (el.hasClass('upload')) {
      RucksackHelpers.requestIframeScript(el, {'is_new': 1}, function(data) { 
        submit_button.attr('disabled', false).html(old_submit); 
        pageController.ResetAndRebind(data); 
      });
      return true;
    }
    else
      RuckSackHelpers.request(el, function(data) { 
        submit_button.attr('disabled', false).html(old_submit); 
        pageController.ResetAndRebind(data); 
      });

    return false;
  }

  onFixedWidgetFormCancel(evt) {
    this.insertionBar.clearWidgetForm();

    return false;
  }

  onAddItemSubmit(evt) {
    var form = $(this);
    RuckSackHelpers.request(form, this.bind(this.JustRebind))
    form[0].reset();
    return false;
  }

  onAddItemCancel(evt) {
    var addItemInner = $(evt.target).parents('.inner:first');
    var newItem = addItemInner.parents('.addItem:first').find('.newItem:first');

    addItemInner.hide();
    addItemInner.children('form')[0].reset();
    newItem.show();

    return false;
  }

  onAddItemLink(evt) {
    var newItem = $(evt.target.parentNode);
    var addItemInner = newItem.parents('.addItem:first').find('.inner:first');

    addItemInner.show();
    addItemInner.autofocus();
    newItem.hide();

    return false;
  }

  onListSubmit(evt) {
    RuckSackHelpers.request($(this), this.bind(this.JustRebind));

    return false;
  }

  onListCancel(evt) {
    var el = $(evt.target);
    var list_url = el.parents('.pageWidget:first').attr('url');
    var item_id = el.parents('.listItem:first').attr('item_id');

    RucksackHelpers.get(this.buildUrl(list_url + '/items/' + item_id), null, this.bind(this.JustRebind));

    return false;
  }

  onListItemCheck(evt) {
    var el = $(evt.target);
    var list_url = el.parents('.pageWidget:first').attr('url');
    var item_id = el.parents('.listItem:first').attr('item_id');

      // Loader gif
    el.siblings('.itemText').html(this.loader());

    RucksackHelpers.put(this.buildUrl(list_url + '/items/' + item_id + '/status'), {'list_item[completed]':evt.target.checked}, this.bind(this.JustRebind));

    return false;
  }

  onListItemDelete(evt) {
    var el = $(evt.target);
    var list_url = el.parents('.pageWidget:first').attr('url');
    var item_id = el.parents('.listItem:first').attr('item_id');

    RucksackHelpers.del(this.buildUrl(list_url + '/items/' + item_id), null, this.bind(this.JustRebind));

    return false;
  }

  onListItemShowMore(evt) {
    var el = $(evt.target);
    var list_url = el.parents('.pageWidget:first').attr('url');

    el.parent().hide();
    RucksackHelpers.get(this.buildUrl(list_url + '/items'), {'completed':1, 'limit':-1, 'offset': 5}, this.bind(this.JustRebind));

    return false;
  }

  onListItemSubmit(evt) {
    RucksackHelpers.request($(this), this.bind(this.JustRebind));

    return false;
  }

  onListItemCancel(evt) {
    var el = $(evt.target);
    var pageList = el.parents('.pageList:first');

    pageList.find('.pageListForm:first').hide();
    pageList.find('.pageListHeader:first').show();

    return false;
  }

  onAlbumSubmit(evt) {
    RuckSackHelpers.request($(this), this.bind(this.JustRebind));  

    return false;
  }

  onAlbumCancel(evt) {
    var el = $(evt.target);
    var pageAlbum = el.parents('.pageAlbum:first');

    pageAlbum.find('.pageAlbumForm:first').hide();
    pageAlbum.find('.pageAlbumHeader:first').show();

    return false;
  }

  onAddAlbumPicture(evt) {
    var newPicture = $(evt.target.parentNode);
    var addPictureInner = newPicture.parents('.albumPictureForm:first').find('.inner:first');

    addPictureInner.show();
    addPictureInner.autofocus();
    newPicture.hide();

    return false;
  }

  onAlbumPictureSubmit(evt) {
    var el = $(this);
    RucksackHelpers.requestIframeScript(el, {}, this.bind(this.JustRebind));
    return true;
  }

  onAlbumPictureCancel(evt) {
    var el = $(this);
    RucksackHelpers.get(el.parents('form:first').attr('action'), null, this.bind(this.JustRebind));
    return false;
  }

  onNewAlbumPictureSubmit(evt) {
    var el = $(this);
    RucksackHelpers.requestIframeScript(el, {'is_new': 1, 'el_id': $(this).parents(".albumPictureForm:first").attr("id")}, this.bind(this.JustRebind));
    return true;
  }

  onNewAlbumPictureCancel(evt) {
    var newPictureInner = $(evt.target).parents('.inner:first');
    var newPicture = newPictureInner.parents('.albumPictureForm:first:first').find('.newPicture:first');

    newPictureInner.hide();
    newPictureInner.children('form')[0].reset();
    newPicture.show();

    return false;
  }

  onEditTags(evt) {
    $(this).request(this.bind(this.JustRebind));

    return false;
  }

  onEditTagsCancel(evt) {
    $('#pageTagsForm').hide();
    $('#pageTags').show();
    $('#pageEditTags').show();

    return false;
  }

  onTagAdd(evt) {
    var crumb = $(evt.target.parentNode);
    var tagName = crumb.attr('tag');
    if (this.TAG_LIST.indexOf(tagName) >= 0)
      return;

    this.TAG_LIST.push(tagName);
    $('#tagCrumbs').append(crumb);
    this.updateTags();

    return false;
  }

  onTagRemove(evt) {
    var crumb = $(evt.target.parentNode);
    var tagName = crumb.attr('tag');

    this.TAG_LIST = $.grep(this.TAG_LIST, function(tag){
      return (tag != tagName);
    });

    $('#tagNewCrumbs').append(crumb);
    this.updateTags();

    return false;
  }

  onReminderSnooze(evt) {
    var el = $(evt.target);
    var reminder_url = el.parents('.reminderEntry:first').attr('url') + '/snooze';
    RucksackHelpers.put(reminder_url, {}, this.bind(this.JustRebind));

    return false;
  }

  onReminderDelete(evt) {
    var el = $(evt.target);
    var reminder_url = el.parents('.reminderEntry:first').attr('url');

    RucksackHelpers.del(reminder_url, {}, this.bind(this.JustRebind));

    return false;
  }

  onReminderSubmit(evt) {
    RucksackHelpers.request($(this), this.bind(this.RebindAndHover));

    return false;
  }

  onReminderCancel(evt) {
    RucksackHelpers.get('/reminders', {}, this.bind(this.JustRebind));

    this.hoverHandle.setEnabled(true);

    return false;
  }

    // User list
  onUserDelete(evt) {
    var el = $(this);

    var user_id = el.parents('tr:first').attr('user_id');

    // TODO: need localization
    if (confirm('Are you sure you want to delete this user?'))
      RucksackHelpers.del('/users/' + user_id, {}, this.bind(this.JustRebind));

    return false;
  }


  // Hover bar which appears when hovering over widgets
  handleHoverSlotBar(evt) {
    var el = $(evt.target);
    var cur = $(this);

    var url = cur.parents(cur.attr('restype') + ':first').attr('url');

    if (el.hasClass('slot_delete') && confirm("Are you sure you want to delete this item?"))
      RucksackHelpers.del(this.buildUrl(url), null, this.bind(this.JustRebind));
    else if (el.hasClass('slot_edit'))
      RucksackHelpers.get(this.buildUrl(url + '/edit'), null, this.bind(this.JustRebind));
    else
      return false;

    return true;
  }

  bindDynamicEvent(el, name, func) {
    this.dynamicBoundEvents.push([el, name, func]);
    el.on(name, func);
  }

  bindStaticEvent(el, name, func) {
    this.staticBoundEvents.push([el, name, func]);
    el.on(name, func);
  }

  clearDynamicEvents() {
    this.dynamicBoundEvents.forEach((item) => {
      item[0].off(item[1], item[2]);
    });
    this.dynamicBoundEvents = [];
  }

  clearStaticEvents() {
    this.staticBoundEvents.forEach((item) => {
      item[0].off(item[1], item[2]);
    });
    this.staticBoundEvents = [];
  }

  bind() {

    this.clearDynamicEvents();

      // Page header
    this.bindDynamicEvent($('#page_header_form form'), 'submit', this.onHeaderSubmit);
    this.bindDynamicEvent($('#page_header_form .cancel'), 'click', this.onHeaderCancel);

    this.bindDynamicEvent($('.pageSlotHandle'), 'click', this.handleHoverSlotBar);

    this.bindDynamicEvent($('.widgetForm'), 'submit', this.onWidgetFormSubmit);
    this.bindDynamicEvent($('.widgetForm .cancel'), 'click', this.onWidgetFormCancel);

    this.bindDynamicEvent($('.fixedWidgetForm'), 'submit', this.onFixedWidgetFormSubmit);
    this.bindDynamicEvent($('.fixedWidgetForm .cancel'), 'click', this.onFixedWidgetFormCancel);

      // Popup form for Add Item
    this.bindDynamicEvent($('.addItem form'), 'submit', this.onAddItemSubmit);
    this.bindDynamicEvent($('.addItem form .cancel'), 'click', this.onAddItemCancel);

      // Add Item link
    this.bindDynamicEvent($('.newItem a'), 'click', this.onAddItemLink);
    this.bindDynamicEvent($('.listItem form'), 'submit', this.onListSubmit);
    this.bindDynamicEvent($('.listItem form .cancel'), 'click', this.onListCancel);

    this.bindDynamicEvent($('.pageList .checkbox'), 'click', this.onListItemCheck);
    this.bindDynamicEvent($('.pageList .itemDelete'), 'click', this.onListItemDelete);

    this.bindDynamicEvent($('.pageList .showItems a'), 'click', this.onListItemShowMore);

    this.bindDynamicEvent($('.pageListForm form'), 'submit', this.onListItemSubmit);
    this.bindDynamicEvent($('.pageListForm form .cancel'), 'click', this.onListItemCancel);

      // Page album
    this.bindDynamicEvent($('.pageAlbumForm'), 'submit', this.onAlbumSubmit);
    this.bindDynamicEvent($('.pageAlbumForm .cancel'), 'click', this.onAlbumCancel);

    this.bindDynamicEvent($('.newPicture a'), 'click', this.onAddAlbumPicture);

      // Edit picture form
    this.bindDynamicEvent($('.albumPicture form'), 'submit', this.onAlbumPictureSubmit);
    this.bindDynamicEvent($('.albumPicture form .cancel'), 'click', this.onAlbumPictureCancel);

      // New picture form
    this.bindDynamicEvent($('.albumPictureForm form'), 'submit', this.onNewAlbumPictureSubmit);
    this.bindDynamicEvent($('.albumPictureForm form .cancel'), 'click', this.onNewAlbumPictureCancel);

      // Page list tags
    this.bindDynamicEvent($('#pageTagsForm form'), 'submit', this.onEditTags);
    this.bindDynamicEvent($('#pageTagsForm .cancel'), 'click', this.onEditTagsCancel);  

      // + -
    this.bindDynamicEvent($('.pageTagAdd'), 'click', this.onTagAdd);
    this.bindDynamicEvent($('.pageTagRemove'), 'click', this.onTagRemove); 

      // Reminder page

    this.bindDynamicEvent($('.reminderSnooze'), 'click', this.onReminderSnooze);
    this.bindDynamicEvent($('.reminderDelete'), 'click', this.onReminderDelete);
    this.bindDynamicEvent($('.reminderForm'), 'submit', this.onReminderSubmit);
    this.bindDynamicEvent($('.reminderForm .cancel'), 'click', this.onReminderCancel);

      // User list
    this.bindDynamicEvent($('#userList .userDelete'), 'click', this.onUserDelete);
  }

    // Handlers

  handleAddList(evt) {
        // Set to top of page if on top toolbar
    if ($(this).hasClass('atTop'))
      this.insertionMarker.set(null, true);

    this.insertWidget('lists');
    this.insertionBar.hide();
    this.insertionMarker.setEnabled(true);
    this.hoverHandle.setEnabled(true);

    return false;
  }

  bindStatic() {

    var pageController = this;

    console.log('bindStatic called');

      // Insert widgets
    this.bindStaticEvent($('.add_List'), 'click', function(evt) {
      evt.preventDefault();

      // Set to top of page if on top toolbar
      if ($(this).hasClass('atTop'))
        pageController.insertionMarker.set(null, true);

      pageController.insertWidget('lists');
      pageController.insertionBar.hide();
      pageController.insertionMarker.setEnabled(true);
      pageController.hoverHandle.setEnabled(true);

      return false;
    });

    this.bindStaticEvent($('.add_Note'), 'click', function(evt) {
      evt.preventDefault();
      
        // Set to top of page if on top toolbar
      if ($(this).hasClass('atTop'))
        pageController.insertionMarker.set(null, true);

      var form = $('#add_NoteForm');

      pageController.insertionBar.setWidgetForm(form);
      pageController.insertionBar.hide();
      pageController.insertionMarker.setEnabled(true);
      pageController.hoverHandle.setEnabled(true);

      form.autofocus();

      return false;
    });

    this.bindStaticEvent($('.add_Separator'), 'click', function(evt) {
      evt.preventDefault();
      
        // Set to top of page if on top toolbar
      if ($(this).hasClass('atTop'))
        pageController.insertionMarker.set(null, true);

      var form = $('#add_SeparatorForm');

      pageController.insertionBar.setWidgetForm(form);
      pageController.insertionBar.hide();
      pageController.insertionMarker.setEnabled(true);
      pageController.hoverHandle.setEnabled(true);

      form.autofocus();

      return false;
    });

    this.bindStaticEvent($('.add_UploadedFile'), 'click', function(evt) {
      evt.preventDefault();
      
        // Set to top of page if on top toolbar
      if ($(this).hasClass('atTop'))
        pageController.insertionMarker.set(null, true);

      var form = $('#add_UploadedFileForm');

      pageController.insertionBar.setWidgetForm(form);
      pageController.insertionBar.hide();
      pageController.insertionMarker.setEnabled(true);
      pageController.hoverHandle.setEnabled(true);

      form.autofocus();

      return false;
    });

    this.bindStaticEvent($('.add_Album'), 'click', function(evt) {
      evt.preventDefault();
      
        // Set to top of page if on top toolbar
      if ($(this).hasClass('atTop'))
        pageController.insertionMarker.set(null, true);

      var form = $('#add_AlbumForm');

      pageController.insertionBar.setWidgetForm(form);
      pageController.insertionBar.hide();
      pageController.insertionMarker.setEnabled(true);
      pageController.hoverHandle.setEnabled(true);

      form.autofocus();

      return false;
    });

      // Page

    this.bindStaticEvent($('#pageInsert'), 'click', function(evt) {
      evt.preventDefault();
      
      pageController.insertionBar.show();
        //console.log('IM SET');
      pageController.insertionMarker.setEnabled(false);
      pageController.insertionMarker.hide();
        //console.log('IM DONE');
      pageController.hoverHandle.setEnabled(false);
      pageController.hoverHandle.clearHandle();

      return false;
    });

    this.bindStaticEvent($('#pageInsertItemCancel a'), 'click', function(evt) {
      evt.preventDefault();
      
      pageController.insertionBar.hide();
      pageController.insertionMarker.setEnabled(true);
      pageController.hoverHandle.setEnabled(true);

      return false;
    });

    this.bindStaticEvent($('#pageSetFavourite'), 'click', function(evt) {
      evt.preventDefault();
      
      RucksackHelpers.put(pageController.buildUrl('/favourite'), {'page[is_favourite]': '1'}, null);
      return false;
    });

    this.bindStaticEvent($('#pageSetNotFavourite'), 'click', function(evt) {
      evt.preventDefault();
      
      RucksackHelpers.put(pageController.buildUrl('/favourite'), {'page[is_favourite]': '0'}, null);
      return false;
    });

    this.bindStaticEvent($('#pageDuplicate'), 'click', function(evt) {
      evt.preventDefault();
      
      $.post(this.buildUrl('/duplicate'), {'foo':1}, null);
      return false;
    });

    this.bindStaticEvent($('#pageDelete'), 'click', function(evt) {
      evt.preventDefault();
      
      if (confirm("Are you sure you want to delete this page?"))
        RucksackHelpers.del(pageController.buildUrl(''), {}, null);
      return false;
    });

    this.bindStaticEvent($('#pageAddress'), 'click', function(evt) {
      evt.preventDefault();
      
      if (evt.target.id == 'pageReset') {
        RucksackHelpers.put(pageController.buildUrl('/reset_address'), {}, null);
        return false;
      }

      return true;
    });

      // Page list tags
    this.bindStaticEvent($('#pageEditTags .edit'), 'click', function(evt) {
      evt.preventDefault();
      console.log('edit...')
      RucksackHelpers.get(pageController.buildUrl('/tags'), {}, pageController.bind(pageController.JustRebind));
      return false;
    });

      // Reminder page

    this.bindStaticEvent($('#add_ReminderForm'), 'submit', function(evt) {
      evt.preventDefault();
      
      RucksackHelpers.request($(this), this.bind(this.JustRebind));

      return false;
    });

      // Journal
    this.bindStaticEvent($('#edit_UserStatus'), 'submit', function(evt) {
      evt.preventDefault();
      
      RucksackHelpers.request($(this), pageController.bind(pageController.JustRebind));

      return false;
    });

    this.bindStaticEvent($('#edit_UserStatus .cancel'), 'click', function(evt) {
      evt.preventDefault();

      $('#user_status_form').hide();
      $('#user_status').show();

      return false;
    });

    this.bindStaticEvent($('#user_status'), 'click', function(evt) {
      if (this.tagName == 'A')
        return true;

      evt.preventDefault();
      
      $('#user_status_form').show();
      $('#user_status').hide();

      return false;
    });

    this.bindStaticEvent($('#userJournal form'), 'submit', function(evt) {
      evt.preventDefault();
      
      var el = $(this);
      if (!el)
        return false;

      RucksackHelpers.request(el, pageController.bind(pageController.JustRebind));

      el[0].reset();

      return false;
    });

    this.bindStaticEvent($('#statusBar'), 'click', function(evt) {
      evt.preventDefault();
      
      $(this).hide('slow');

      return false;
    });

      // Journal
    this.bindStaticEvent($('#userJournalsMore a'), 'click', function(evt) {
      evt.preventDefault();
      
      var element = $(this);
      var toggleLoader = function(el, visible){
        var parent = el.parent();
        if (visible)
        {
          parent.children('a').hide();
          parent.children('.loader').show();
        }
        else
        {
          parent.children('a').show();
          parent.children('.loader').hide();
        }
      };

      toggleLoader(element, true);

      $.ajax({url: "/journals",
        data: {'from': this.bindStaticEvent($('#userJournalsMore'), 'attr', 'from')},
        success(data) {
          toggleLoader(element, false);
          pageController.ResetAndRebind(data);
        },
        failure(data) {
          toggleLoader(element, false);
          pageController.ResetAndRebind(data);
        },
        dataType: 'script'});

      return false;
    });

    // Page sidebar
    this.bindStaticEvent($('.addPageLink a'), 'click', function(evt) {
      evt.preventDefault();
      
      var newPage = $(evt.target.parentNode);
      var addPageInner = newPage.parents('.addPage:first').find('.inner:first');

      addPageInner.show();
      addPageInner.autofocus();
      newPage.hide();

      return false;
    });

    this.bindStaticEvent($('.addPage form'), 'submit', function(evt) {
      evt.preventDefault();
      
      var el = $(this);
      var submit_button = el.find('.submit:first');
      var root = el.parents('.addPage:first');
      var newPage = root.find('.addPageLink:first');
      var addPageInner = root.find('.inner:first');

        // Loader
      var old_submit = submit_button.html();
      submit_button.attr('disabled', true).html(this.loader());

      RucksackHelpers.request($(this), function(data){
        addPageInner.hide(); 
        newPage.show();
        submit_button.attr('disabled', false).html(old_submit);
        pageController.ResetAndRebind(data);
      });

      return false;
    });

    this.bindStaticEvent($('.addPage form .cancel'), 'click', function(evt) {
      evt.preventDefault();
      
      var root = $(evt.target.parentNode).parents('.addPage:first');
      var newPage = root.find('.addPageLink:first');
      var addPageInner = root.find('.inner:first');

      addPageInner.hide();
      newPage.show();

      return false;
    });
  }

  rebind () {
    this.clearDynamicEvents();
    this.bind();
  }

  setFavourite(favourite) {
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
  }

  loader() {
    return $('#loader_template').html();
  }

  insertWidget(resource) {
    if (this.READONLY)
      return;

        // Insert
    $.post('/pages/' + this.ID + '/' + resource, 
      {'position[slot]': $(this.insert_element).attr('slot') , 
      'position[before]': (this.insert_before ? '1' : '0')}, this.ResetAndRebind);
  }

  dropSlotFunction (ev, ui) {
      // Add all of the wrapped elements
    if (this.isSortingWrappedElements) {
      var page_id = $(this).attr('page_id');
      ui.draggable.children(":last").children().each(function() {
        this.moveSlotTo($(this).attr('slot'), page_id);
      });
    }
    this.moveSlotTo(ui.draggable.attr('slot'), $(this).attr('page_id'));
  }

  makeSortable() {
    return; // TOFIX
    if (this.READONLY)
      return;

    var lists = $('.pageList .openItems .listItems');

    lists.each(function(i) {
      this.makeListSortable($(this));
    });

        // Refresh so we can drag between
    lists.each(function(i) {
      $(this).sortable('refresh');
    });

        // Add droppables
    $('#stdPageListItems li').each(function(i) {
      var el = $(this);
      if (!el.hasClass('current'))
      {
            //el.droppable('destroy');
        el.droppable({ hoverClass:'hover', accept:'.pageSlot', tolerance: 'pointer', drop:this.dropSlotFunction});
      }
    });

    $('#usrPageListItems li').each(function(i) {
      var el = $(this);
      if (!el.hasClass('current'))
      {
        el.droppable({ hoverClass:'hover', accept:'.pageSlot', tolerance: 'pointer', drop:this.dropSlotFunction});
      }
    });

        // Make sidebar sortable
    if ($('#usrPageListItems').data('sortable'))
    {
      $('#usrPageListItems').sortable('destroy');
    }

    $('#usrPageListItems').sortable({
      axis: 'y',
      handle: '.usr_page_handle',
      items: '> .sidebar_page',
      opacity: 0.75,
      update(e, ui)
      {
        $.post('/pages/reorder_sidebar', $('#usrPageListItems').sortable('serialize', {key: 'page_ids[]'}));
      }
    });

        // Make slots sortable
    if ($('#slots').data('sortable'))
    {
      $('#slots').sortable('destroy');
    }

    $('#slots').sortable({
      axis: 'y',
      handle: '.slot_handle',
      items: '> .pageSlot',
      opacity: 0.75,
      start(e, ui) {
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

          this.isSortingWrappedElements = true;
        }
      },
      stop(e, ui) {
        if (this.isSortingWrappedElements)
          this.stopSortingWrappedElements(ui.item);
      },
      update(e, ui) {
        if (this.isSortingWrappedElements)
          this.stopSortingWrappedElements(ui.item);
        $.post('/pages/' + this.ID + '/reorder', $('#slots').sortable('serialize', {key: 'slots[]'}));
      }
    });                           
  }

  moveSlotTo(slot_id, page_id) {
    if (page_id != '0' && page_id != 0)
      RucksackHelpers.put('/pages/' + page_id + '/' + 'transfer', {'page_slot[id]': slot_id }, null);
  }

  makeListSortable(el) {
    return; // TOFIX
    var list_url = el.parents('.pageWidget:first').attr('url');

    if (el.data('sortable'))
    {
      el.sortable('destroy');
    }

    el.sortable({
      axis: 'y',
      handle: '.slot_handle',
      connectWith: ['.pageList .openItems .listItems'],
      opacity: 0.75,
      update(e, ui) {
            // Check for item movement vs item update. Note that the 
            // list the item is moved to will do its own update after.

        var list = ui.item.parent('.listItems');
        if (list.attr('id') != $(this).attr('id'))
          RucksackHelpers.put('/pages/' + this.ID + list.parents('.pageWidget:first').attr('url') + '/transfer', {'list_item[id]': ui.item.attr('item_id')});
        else
          $.post('/pages/' + this.ID + list_url + '/reorder', el.sortable('serialize', {key: 'items[]'}));
      }
    }); 
  }


  // Event handlers


  // Hover observer for HoverHandle
  handlePageHoverHandlerFunc(evt){
    if (!this.hoverHandle.enabled)
      return;

    var el = $(evt.target);

    var hover = null;
    var handler = el.attr('hover_handle');
    if (handler)
      hover = $('#' + handler);
    else if (el.hasClass('innerHandle'))
      hover = el.parents('.pageSlotHandle:first');

    if (hover)
      this.hoverHandle.setHandle(hover);
    else
      this.hoverHandle.clearHandle();
  }

  handlePageHoverHandlerCancelFunc(evt){
    this.hoverHandle.clearHandle();
  }

  // Hover observer for InsertionMarker
  handleInsertionMarkerFunc(evt){
    if (!this.insertionMarker.enabled)
      return;

    var el = $(evt.target);
    var pt = [evt.clientX, evt.clientY];
    pt.x = pt[0]; pt.y = pt[1];
    var offset = el.offset();

    if (!(pt.x - offset.left > this.MARGIN))
    {
      if (el.hasClass('pageSlot'))
      {
        var h = el.height(), thr = Math.min(h / 2, this.SLOT_VERGE);
        var t = offset.top, b = t + h;

        if (el.hasClass('pageFooter')) // before footer
          this.insertionMarker.show(el, true);
        else if (pt.y - t <= thr) // before element
          this.insertionMarker.show(el, true);
        else if (b - pt.y <= thr) // after element
          this.insertionMarker.show(el, false);
        else
           this.insertionMarker.hide(); // *poof*           
      }
    }
    else
    {
    // Handle offset when hovering over insert bar
      if (el.attr('id') == "cpi") 
      {
        if (!(pt.x - offset.left > (90+this.MARGIN)))
          return;
      }

      this.insertionMarker.hide(); // *poof*
    }
  }

  sel(selector) {
    return $(selector);
  }

  JustRebind(data) {
    this.rebind();
  }

  RebindAndHover(data) {
    this.rebind();
    this.hoverHandle.setEnabled(true);
  }

  ResetAndRebind(data) {
    // Clean up state
    if (this.TYPE == 'page')
    {
      this.insertionBar.hide();
      this.insertionBar.clearWidgetForm();
    }

    this.rebind();
  }
};

