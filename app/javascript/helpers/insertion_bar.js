import $ from "cash-dom";
import Velocity from "velocity-animate";

// Insertion bar which appears between slots
export default class {

  constructor(pageController) {
    this.current_form = null;
    this.pageController = pageController;
  }

  init() {
    var root = $(this.pageController.element);
    this.element = root.find('#pageInsertItems');
    this.element_bar  = root.find('#pageInsertItemsBar');
    this.element_tablet = root.find('#pageTabletContainer');
  }

  show() {
    $(this.pageController.insertionMarker.element).before(this.element);
    this.element_bar.css('height', '0px').show();

    Velocity(this.element_bar[0], {
      'height': '25px'
    },
    {
      duration: 32,
      complete: () => {
        this.element_bar.css('height', null).show();
      }
    });
  }

  hide() {
    this.element_bar.hide();
  }

  magicForm(el) {
    // Reveal form using an expanding blind effect
    var calc_height = el.height();
    var init = true;
    el.css({'height': '128px', 'overflow': 'hidden'});

    Velocity(this.element_bar[0], {
      'height': calc_height + 'px'
      },
      {
      duration: 32,
      complete: (evt) => {
        // Defaults
        el.css('height', null).css('overflow', 'visible');
      }
    } 
    );
  }

  // Widget form
  setWidgetForm(template) {
    if (this.current_form)
      this.clearWidgetForm();

        // Set insertion position
    var id = template.attr('id');
    var root = $(this.pageController.element);
    root.find('#' + id + 'Before').attr('value', this.pageController.insert_before ? '1' : '0');
    root.find('#' + id + 'Slot').attr('value', $(this.pageController.insert_element).attr('slot'));

    // Form should go in the insertion bar, so we can change the insertion location and maintain
    // state
    this.element_tablet.append(template);
    this.magicForm(root.find('#' + id));
    this.current_form = template;
  }

  clearWidgetForm() {
    if (!this.current_form)
      return;

    var root = $(this.pageController.element);
    this.current_form.children('form')[0].reset();
    root.find('#pageWidgetForms').append(this.current_form);
    this.current_form = null;
  }
};
