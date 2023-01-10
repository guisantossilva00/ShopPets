/* eslint-disable no-alert */
import { LightningElement, track, api } from "lwc";

const REFRESH_PIX_EVENT = "clickrefreshpix";

export default class PagBrasilPixPaymentMethod extends LightningElement {
  _pixImage;
  _pixCode;
  _pixLoading = false;
  _isConnected = false;

  @track _pixActive = false;

  /**
   * Check if pix is loading
   * @type {String}
   */
  @api
  get pixLoading() {
    return this._pixLoading;
  }

  set pixLoading(loading) {
    this._pixLoading = loading;
  }

  /**
   * Display or hide Pix
   * @type {Boolean}
   */
  @api
  get pixActive() {
    return this._pixActive;
  }

  set pixActive(active) {
    this._pixActive = active;
  }

  /**
   * Get and set pix image
   * @type {Boolean}
   */
  @api
  get pixImage() {
    return this._pixImage;
  }

  set pixImage(image) {
    this._pixImage = image;
  }

  /**
   * Get and set pix code
   * @type {Boolean}
   */
  @api
  get pixCode() {
    return this._pixCode;
  }

  set pixCode(code) {
    this._pixCode = code;
  }

  /**
   * Shows or clears validation errors on inputs that comprise the component, returns true if required
   * fields have been filled.
   *
   * @returns {Boolean}
   *  True if required fields have been filled, false otherwise.
   */
  @api
  reportValidity() {
    if (!this._isConnected) {
      return true;
    }

    const incompleteFields = false;

    const componentsToValidate =
      this.template.querySelectorAll("[data-validate]");

    // Need to run .reportValidity on all components to ensure that all errors are shown/cleared at once
    const validateFields = [...componentsToValidate].reduce(
      (result, component) => component.reportValidity() && result,
      true
    );

    return !incompleteFields && validateFields;
  }

  handlePixCopyPaste() {
    this.copyTextToClipboard(this._pixCode);
  }

  copyTextToClipboard(content) {
    let tempTextAreaField = document.createElement("textarea");

    tempTextAreaField.style = "position:fixed;top:-5rem;height:1px;width:10px;";
    tempTextAreaField.value = content;

    document.body.appendChild(tempTextAreaField);
    tempTextAreaField.select();

    document.execCommand("copy");
    tempTextAreaField.remove();

    alert("Copiado!");
  }

  @api
  enablePixRefresh() {
    this.template.querySelector("img").className = "cursor-pointer";
  }

  @api
  disablePixRefresh() {
    this.template.querySelector("img").className = "";
  }

  handlePixImageClick() {
    this.dispatchEvent(new CustomEvent(REFRESH_PIX_EVENT, {}));
  }

  connectedCallback() {
    this._isConnected = true;
  }

  disconnectedCallback() {
    this._isConnected = false;
  }
}