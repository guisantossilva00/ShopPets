/* eslint-disable radix */
/* eslint-disable eqeqeq */
/* eslint-disable @lwc/lwc/no-async-operation */
/* eslint-disable @lwc/lwc/no-api-reassignments */

import { LightningElement, api } from "lwc";
import { loadScript } from "lightning/platformResourceLoader";

import {
  FlowNavigationNextEvent,
  FlowAttributeChangeEvent
} from "lightning/flowSupport";

import * as Constants from "./constants";

import requestOrderInformationFromOrderNumber from "@salesforce/apex/PagBrasilPaymentController.requestOrderInformationFromOrderNumber";
import requestPixOrderInformation from "@salesforce/apex/PagBrasilPaymentController.requestPixOrderInformation";
import setOrderStatusAsRejected from "@salesforce/apex/PagBrasilPaymentController.setOrderStatusAsRejected";
import setOrderStatusAsFailed from "@salesforce/apex/PagBrasilPaymentController.setOrderStatusAsFailed";
import getCheckoutInfo from "@salesforce/apex/PagBrasilPaymentController.getCheckoutInfo";
import makePayment from "@salesforce/apex/PagBrasilPaymentController.makePayment";

import boletoFlashLogo from "@salesforce/resourceUrl/boletoFlash";
import creditCardLogo from "@salesforce/resourceUrl/creditCard";
import debitCardLogo from "@salesforce/resourceUrl/debitoFlash";
import pecFlashLogo from "@salesforce/resourceUrl/pecFlash";
import pixLogo from "@salesforce/resourceUrl/pix";

import qrRel from "@salesforce/resourceUrl/qrRel";
import qrExp from "@salesforce/resourceUrl/qrExp";

import konduto from "@salesforce/resourceUrl/k";

/**
 * Allows users to choose the type of payment (Credit Card, Debito Flash, PEC Flash, Boleto Flash and Pix)
 * and to fill out the required information for the chosen type.
 *
 * @fires FlowNavigationNextEvent
 * @fires PaymentMethod#makePayment
 */
export default class PagBrasilPaymentMethods extends LightningElement {
  _addresses;
  _errorMessage;
  _cartId;
  _taxId;
  _checkoutSettings;

  _order;
  _token;

  _pixActive = false;
  _pixLoading = false;
  _pixImage;
  _pixOldImage;
  _pixCode;
  _pixCycles = 0;
  _pixMaxCycles = 12;
  _pixInterval;

  _selectedBillingAddress = {};
  _newBillingAddress = {};
  _contactPointAddressId = 0;
  _selectedPaymentType = Constants.paymentTypeEnum.CARD_PAYMENT;

  _creditCardLogoUrl = creditCardLogo;
  _debitCardLogoUrl = debitCardLogo;
  _boletoFlashLogoUrl = boletoFlashLogo;
  _pecLogoUrl = pecFlashLogo;
  _pixLogoUrl = pixLogo;
  _qrRelUrl = qrRel;
  _qrExpUrl = qrExp;

  @api nextButtonLabel = Constants.labels.NextButtonLabel;
  @api paymentHeaderLabel = Constants.labels.PaymentHeaderLabel;
  @api billingHeaderLabel = Constants.labels.BillingHeaderLabel;
  @api isLoaded = false;

  @api
  get isLoadedAndPixNotActive() {
    return !this.isPixPaymentSelectedAndPixActive && this.isLoaded;
  }

  @api
  get contactPointAddressId() {
    return this._contactPointAddressId;
  }

  @api
  get cartId() {
    return this._cartId;
  }

  @api
  get selectedPaymentType() {
    return this._selectedPaymentType;
  }

  @api
  get selectedBillingAddress() {
    return Object.keys(this._selectedBillingAddress).length
      ? this._selectedBillingAddress
      : this._newBillingAddress;
  }

  @api
  get contactPointAddressRecord() {
    return this._newBillingAddress;
  }

  @api
  get taxId() {
    return this._taxId;
  }

  @api
  reportValidity() {
    if (!this._isConnected) {
      return true;
    }

    const incompleteFields = this.hasIncompletePaymentFields();

    const componentsToValidate =
      this.template.querySelectorAll("[data-validate]");

    const validateFields = [...componentsToValidate].reduce(
      (result, component) => component.reportValidity() && result,
      true
    );

    return !incompleteFields && validateFields;
  }

  get labels() {
    return Constants.labels;
  }

  set selectedPaymentType(newPaymentType) {
    this._selectedPaymentType = newPaymentType;
  }

  get checkoutSettings() {
    return this._checkoutSettings;
  }

  set cartId(cartId) {
    this._cartId = cartId;
    if (cartId) {
      this.initializePaymentData(cartId);
    }
  }

  get activePaymentMethods() {
    if (this._checkoutSettings) {
      return this._checkoutSettings.payment_methods.split("");
    }

    return [];
  }

  get userAccountId() {
    if (this._checkoutSettings) {
      return this._checkoutSettings.account_id;
    }

    return "";
  }

  get paymentTypes() {
    return {
      cardPayment: Constants.paymentTypeEnum.CARD_PAYMENT,
      debitPayment: Constants.paymentTypeEnum.DEBIT_PAYMENT,
      boletoPayment: Constants.paymentTypeEnum.BOLETO_PAYMENT,
      pecPayment: Constants.paymentTypeEnum.PEC_PAYMENT,
      pixPayment: Constants.paymentTypeEnum.PIX_PAYMENT
    };
  }

  get isCardPaymentActive() {
    return this.paymentMethodIsActive(Constants.paymentTypeEnum.CARD_PAYMENT);
  }

  get isCardPaymentSelected() {
    return this._selectedPaymentType === Constants.paymentTypeEnum.CARD_PAYMENT;
  }

  get isDebitPaymentActive() {
    //return this.paymentMethodIsActive(Constants.paymentTypeEnum.DEBIT_PAYMENT);
    return false;
  }

  get isDebitPaymentSelected() {
    return (
      this._selectedPaymentType === Constants.paymentTypeEnum.DEBIT_PAYMENT
    );
  }

  get isBoletoPaymentActive() {
    return this.paymentMethodIsActive(Constants.paymentTypeEnum.BOLETO_PAYMENT);
  }

  get isBoletoPaymentSelected() {
    return (
      this._selectedPaymentType === Constants.paymentTypeEnum.BOLETO_PAYMENT
    );
  }

  get isPecPaymentActive() {
    return this.paymentMethodIsActive(Constants.paymentTypeEnum.PEC_PAYMENT);
  }

  get isPecPaymentSelected() {
    return this._selectedPaymentType === Constants.paymentTypeEnum.PEC_PAYMENT;
  }

  get isPixPaymentActive() {
    return this.paymentMethodIsActive(Constants.paymentTypeEnum.PIX_PAYMENT);
  }

  get isPixPaymentSelected() {
    return this._selectedPaymentType === Constants.paymentTypeEnum.PIX_PAYMENT;
  }

  get isPixPaymentSelectedAndPixActive() {
    return (
      this._pixActive &&
      this._selectedPaymentType === Constants.paymentTypeEnum.PIX_PAYMENT
    );
  }

  initializePaymentData(cartId) {
    getCheckoutInfo({ cartId: cartId })
      .then((data) => {
        this._checkoutSettings = data;
        this.isLoaded = true;

        if (this._checkoutSettings?.public_key) {
          this.loadKondutoScript();
        }
      })
      .catch((error) => {
        console.log(error.body.message);
      });
  }

  paymentMethodIsActive(paymentMethod) {
    return this.activePaymentMethods.includes(paymentMethod);
  }

  handlePaymentTypeSelected(event) {
    this._selectedPaymentType = event.currentTarget.value;
    this._errorMessage = false;
  }

  handlePaymentButton() {
    let paymentData = {};

    if (!this.reportValidity()) {
      return;
    }

    const billingAddressComponent = this.getComponent(
      "[data-pagbrasil-billing-address]"
    );

    if (
      billingAddressComponent != null &&
      !billingAddressComponent.reportValidity()
    ) {
      return;
    }

    if (this.isCardPaymentSelected) {
      const creditPaymentComponent = this.getComponent(
        "[data-pagbrasil-credit-card-payment-method]"
      );

      if (
        creditPaymentComponent != null &&
        !creditPaymentComponent.reportValidity()
      ) {
        return;
      }

      paymentData = this.getCreditCardFromComponent(creditPaymentComponent);
    }

    paymentData.taxId = this._taxId;
    paymentData.visitorId = window.Konduto
      ? window.Konduto.getVisitorID()
      : null;

    this._errorMessage = false;
    this.isLoaded = false;

    makePayment({
      paymentType: this.selectedPaymentType,
      cartId: this.cartId,
      paymentInfo: paymentData,
      paymentBillingAddress: this.selectedBillingAddress
    })
      .then((response) => {
        this.isLoaded = true;

        if (!this.isPixPaymentSelected) {
          const navigateNextEvent = new FlowNavigationNextEvent();
          this.dispatchEvent(navigateNextEvent);
          return true;
        }

        if (response.success === "true" && this.isPixPaymentSelected) {
          this._pixLoading = true;
          this.getPixInformation(response.order, response.token);
          return true;
        }

        this._pixImage = this._qrExpUrl;
        return true;
      })
      .catch((error) => {
        this.isLoaded = true;

        if (!error.body || !error.body.message) {
          return;
        }

        try {
          const json = JSON.parse(error.body.message);
          this._errorMessage = json?.output?.gatewayResponse?.gatewayMessage;

          let statusCode = json?.output?.gatewayResponse?.gatewayResultCode;
          if (statusCode == "PF") {
            setOrderStatusAsFailed({
              cartId: this.cartId
            });
            this._errorMessage = "Pagamento não autorizado pelo banco emissor.";
          }

          if (statusCode == "PR") {
            setOrderStatusAsRejected({
              cartId: this.cartId
            });
            this._errorMessage =
              "Pagamento não autorizado, por favor tente novamente mais tarde.";
          }

          if (!this._errorMessage) {
            this._errorMessage = json?.output?.error?.message;
          }
        } catch (e) {
          this._errorMessage =
            "Erro desconhecido. Por favor, repita o processo de compra ou tente novamente mais tarde.";
        }
      });
  }

  getPixInformation(order, token) {
    this._pixActive = true;

    requestOrderInformationFromOrderNumber({
      orderNumber: order
    })
      .then((response) => {
        const parser = new DOMParser();
        const xmlDoc = parser.parseFromString(response, "text/xml");

        this._pixImage =
          xmlDoc.getElementsByTagName("pix_image")[0].childNodes[0].nodeValue;
        this._pixCode =
          xmlDoc.getElementsByTagName("pix_code")[0].childNodes[0].nodeValue;
        this._pixLoading = false;

        this._order = order;
        this._token = token;

        this._pixInterval = setInterval(this.pixCheck.bind(this), 5000);
      })
      .catch((error) => console.error(error));
  }

  getCreditCardFromComponent(creditPaymentComponent) {
    const cardPaymentData = {};
    [
      "cardHolderName",
      "cardNumber",
      "cardInstallments",
      "cvv",
      "expiryMonth",
      "expiryYear"
    ].forEach((property) => {
      cardPaymentData[property] = creditPaymentComponent[property];
    });
    return cardPaymentData;
  }

  /**
   * Format input Holder TaxId
   *
   * @private
   */
  formatTaxId(keyboardEvent) {
    let field = keyboardEvent.target;

    if (field.value.length <= 14) {
      field.value = field.value
        .replace(/\D/g, "")
        .replace(/(\d{3})(\d)/, "$1.$2")
        .replace(/(\d{3})(\d)/, "$1.$2")
        .replace(/(\d{3})(\d{1,2})$/, "$1-$2");

      if (this.isValidCpf(field.value)) {
        field.setCustomValidity("");
      }

      if (!this.isValidCpf(field.value)) {
        field.setCustomValidity("Por favor, informe um CPF válido.");
      }
    }

    if (field.value.length > 14) {
      field.value = field.value
        .replace(/\D/g, "")
        .replace(/^(\d{2})(\d)/, "$1.$2")
        .replace(/^(\d{2})\.(\d{3})(\d)/, "$1.$2.$3")
        .replace(/\.(\d{3})(\d)/, ".$1/$2")
        .replace(/(\d{4})(\d)/, "$1-$2");

      if (this.isValidCnpj(field.value)) {
        field.setCustomValidity("");
      }

      if (!this.isValidCnpj(field.value)) {
        field.setCustomValidity("Por favor, informe um CNPJ válido.");
      }
    }

    field.reportValidity();
  }

  handleBillingAddressChange(event) {
    if (event.detail.address.Id) {
      const address = event.detail.address.Address;
      this._selectedBillingAddress = {
        Name: event.detail.address.Name,
        Street: address.street,
        City: address.city,
        State: address.state,
        PostalCode: address.postalCode
      };
      this._contactPointAddressId = event.detail.address.Id;
      return;
    }

    const address = event.detail.address;
    const supplement = address.supplement ? address.supplement : "-";
    const neighborhood = address.neighborhood ? address.neighborhood : "-";

    this._selectedBillingAddress = {};
    this._newBillingAddress = {
      Name: "Endereço de faturamento",
      Street: `${address.street}, ${address.number} - ${supplement} - Bairro ${neighborhood}`,
      City: address.city,
      State: address.state,
      Country: "Brasil",
      AddressType: "Billing",
      PostalCode: address.postalCode,
      ParentId: this.userAccountId
    };

    const attributeChangeEvent = new FlowAttributeChangeEvent(
      "contactPointAddressRecord",
      this.contactPointAddressRecord
    );

    this.dispatchEvent(attributeChangeEvent);
  }

  handlePixRefreshClick() {
    if (this._pixCycles <= this._pixMaxCycles) {
      return false;
    }

    this._pixCycles = 0;
    this._pixImage = this._pixOldImage;
    this.template
      .querySelector("c-pag-brasil-pix-payment-method")
      .disablePixRefresh();

    this._pixInterval = setInterval(this.pixCheck.bind(this), 5000);

    return true;
  }

  handleTaxIdChange(event) {
    this._taxId = event.target.value;
    event.target.reportValidity();
  }

  pixCheck() {
    requestPixOrderInformation({
      orderId: this._order,
      token: this._token
    })
      .then((pixResponse) => {
        const pixJson = JSON.parse(pixResponse);
        if (pixJson.status === "PC") {
          const navigateNextEvent = new FlowNavigationNextEvent();
          this.dispatchEvent(navigateNextEvent);
        }

        if (pixJson.status === "PR") {
          this._pixImage = this._qrExpUrl;
        }
      })
      .catch((error) => console.error(error));

    this._pixCycles++;

    if (this._pixCycles > this._pixMaxCycles) {
      this._pixOldImage = this._pixImage;
      this._pixImage = this._qrRelUrl;

      this.template
        .querySelector("c-pag-brasil-pix-payment-method")
        .enablePixRefresh();
      clearInterval(this._pixInterval);
    }
  }

  loadKondutoScript() {
    window.__kdt = window.__kdt || [];
    window.__kdt.push({ public_key: this._checkoutSettings.public_key });

    loadScript(this, konduto).then(() => {});
  }

  hasIncompletePaymentFields() {
    const fieldRequiredValueMap = [
      {
        isRequiredAttr: true,
        value: this._taxId,
        error: this.labels.InvalidTaxId
      }
    ];

    const isInvalidField = fieldRequiredValueMap.find((field) => {
      return field.isRequiredAttr && !field.value;
    });

    return isInvalidField;
  }

  getComponent(locator) {
    return this.template.querySelector(locator);
  }

  isValidCpf(cpf) {
    cpf = cpf.replace(/[^\d]+/g, "");

    if (cpf.length != 11) {
      return false;
    }

    if (
      cpf.length != 11 ||
      cpf == "00000000000" ||
      cpf == "11111111111" ||
      cpf == "22222222222" ||
      cpf == "33333333333" ||
      cpf == "44444444444" ||
      cpf == "55555555555" ||
      cpf == "66666666666" ||
      cpf == "77777777777" ||
      cpf == "88888888888" ||
      cpf == "99999999999" ||
      cpf == "01234567890"
    ) {
      return false;
    }

    let add = 0,
      rev;
    for (let i = 0; i < 9; i++) {
      add += parseInt(cpf.charAt(i)) * (10 - i);
    }

    rev = 11 - (add % 11);
    if (rev == 10 || rev == 11) {
      rev = 0;
    }

    if (rev != parseInt(cpf.charAt(9))) {
      return false;
    }

    add = 0;
    for (let i = 0; i < 10; i++) {
      add += parseInt(cpf.charAt(i)) * (11 - i);
    }

    rev = 11 - (add % 11);
    if (rev == 10 || rev == 11) {
      rev = 0;
    }

    return rev == parseInt(cpf.charAt(10));
  }

  isValidCnpj(cnpj) {
    cnpj = cnpj.replace(/[^\d]+/g, "");

    if (cnpj.length != 14) {
      return false;
    }

    if (
      cnpj == "00000000000000" ||
      cnpj == "11111111111111" ||
      cnpj == "22222222222222" ||
      cnpj == "33333333333333" ||
      cnpj == "44444444444444" ||
      cnpj == "55555555555555" ||
      cnpj == "66666666666666" ||
      cnpj == "77777777777777" ||
      cnpj == "88888888888888" ||
      cnpj == "99999999999999"
    ) {
      return false;
    }

    let size = cnpj.length - 2;
    let numbers = cnpj.substring(0, size);
    let digits = cnpj.substring(size);

    let sum = 0,
      pos = size - 7,
      result = 0;

    for (let i = size; i >= 1; i--) {
      sum += numbers.charAt(size - i) * pos--;
      if (pos < 2) {
        pos = 9;
      }
    }

    result = sum % 11 < 2 ? 0 : 11 - (sum % 11);
    if (result != digits.charAt(0)) {
      return false;
    }

    size = size + 1;
    numbers = cnpj.substring(0, size);
    sum = 0;
    pos = size - 7;

    for (let i = size; i >= 1; i--) {
      sum += numbers.charAt(size - i) * pos--;
      if (pos < 2) {
        pos = 9;
      }
    }

    result = sum % 11 < 2 ? 0 : 11 - (sum % 11);
    return result == digits.charAt(1);
  }

  connectedCallback() {
    this._isConnected = true;
  }

  disconnectedCallback() {
    this._isConnected = false;
  }
}