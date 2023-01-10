/* eslint-disable @lwc/lwc/no-async-operation */
/* eslint-disable @lwc/lwc/no-api-reassignments */
import { api, LightningElement } from "lwc";

import requestOrderInformationFromSummary from "@salesforce/apex/PagBrasilPaymentController.requestOrderInformationFromSummary";

export default class PagBrasilPaymentConfirmation extends LightningElement {
  _isLoaded = false;
  _boletoCreated = false;
  _orderPaymentSummary;
  _boletoUrl;
  _paymentInstructions;

  @api isBoletoPayment = false;
  @api isPecPayment = false;
  @api isPixPayment = false;

  @api
  get boletoUrl() {
    return this._boletoUrl;
  }

  @api
  get paymentInstructions() {
    return this._paymentInstructions;
  }

  @api
  get orderPaymentSummary() {
    return this._orderPaymentSummary;
  }

  set orderPaymentSummary(summary) {
    this._orderPaymentSummary = summary;
  }

  connectedCallback() {
    this.getOrderInformation();
  }

  renderedCallback() {
    if (this._boletoCreated) {
      return;
    }

    if (!this._boletoUrl) {
      return;
    }

    const containerElem = this.template.querySelector(".pagbrasil-container");
    const iframe = document.createElement("iframe");

    iframe.src = this._boletoUrl;
    iframe.classList.add("pb-iframe");
    iframe.width = "100%";
    iframe.height = "750px";
    iframe.setAttribute("frameborder", "0");

    if (containerElem) {
      containerElem.appendChild(iframe);
    }

    this._boletoCreated = true;

    window.setTimeout(
      function () {
        this._isLoaded = true;
        this.template
          .querySelector(".pagbrasil-container")
          .classList.remove("slds-hide");
      }.bind(this),
      1500
    );
  }

  getOrderInformation() {
    requestOrderInformationFromSummary({
      summaryId: this.orderPaymentSummary
    })
      .then((response) => {
        const parser = new DOMParser();
        const xmlDoc = parser.parseFromString(response, "text/xml");

        const paymentMethod =
          xmlDoc.getElementsByTagName("payment_method")[0].childNodes[0]
            .nodeValue;

        if (paymentMethod === "B") {
          this._boletoUrl =
            xmlDoc.getElementsByTagName("url_boleto")[0].childNodes[0]
              .nodeValue + "&mobile=1&iframe=1";
          this.isBoletoPayment = true;
        }

        if (paymentMethod === "P") {
          this._paymentInstructions = xmlDoc
            .getElementsByTagName("payment_instructions")[0]
            .childNodes[0].nodeValue.replaceAll("\\n", "<br>")
            .toString();
          this.isPecPayment = true;
          this._isLoaded = true;
        }

        if (paymentMethod === "X") {
          this._pixImage =
            xmlDoc.getElementsByTagName("pix_image")[0].childNodes[0].nodeValue;
          this._pixCode =
            xmlDoc.getElementsByTagName("pix_code")[0].childNodes[0].nodeValue;
          this.isPixPayment = true;
          this._isLoaded = true;
        }
      })
      .catch((error) => console.error(error));
  }
}