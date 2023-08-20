import $ from "cash-dom";

// Insertion marker which appears between slots
export default class {

  constructor(pageController) {
    this.pageController = pageController;
  }

  init() {
    console.log('woop',this);
    console.log("el=",this.pageController.element);
    this.element = $(this.pageController.element).find('#pageInsert');
    this.enabled = true;
    this.visible = false;
  }

  setEnabled(val) {
    this.enabled = val;
  }

  show(el, insert_before) {
    this.visible = true;
    this.set(el, insert_before);
    this.element.show();
  }

  hide() {
    if (this.visible) {
      this.element.hide();
      this.visible = false;

      if (this.enabled)
      {
        this.set(null, true);
      }
    }
  }

  set(element, insert_before) {
    var el = element ? 
      element : 
      $(this.pageController.element).find('#slots').children('.pageSlot')[0];

    this.pageController.insert_element = el;
    this.pageController.insert_before = insert_before;

    if (insert_before)
      el.before(this.element);
    else
      el.after(this.element);
  }
};