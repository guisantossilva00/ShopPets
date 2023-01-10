/* eslint-disable no-cond-assign */
import { api, LightningElement } from "lwc";
import * as Constants from "./constants.js";

export default class PagBrasilCreditCardPaymentMethod extends LightningElement {
  // Private attributes
  _checkoutSettings;
  _cardHolderName;
  _cardNumber;
  _cvv;
  _expiryMonth;
  _expiryYear;
  _feeTotal;
  _cardInstallments = "";
  _isConnected = false;
  _showFeeText = false;

  /**
   * Gets or sets the name of the card holder.
   *
   * The value of this property is updated in response to user interactions with the control.
   *
   * @type {String}
   */
  @api
  get cardHolderName() {
    return this._cardHolderName;
  }

  /**
   * Gets or sets the card number.
   *
   * The value of this property is updated in response to user interactions with the control.
   *
   * @type {String}
   */
  @api
  get cardNumber() {
    return this._cardNumber;
  }

  /**
   * Gets or sets the card installments.
   *
   * The value of this property is updated in response to user interactions with the control.
   *
   * @type {String}
   */
  @api
  get cardInstallments() {
    return this._cardInstallments;
  }

  /**
   * Gets or sets the card verification value.
   *
   * The value of this property is updated in response to user interactions with the control.
   *
   * @type {String}
   */
  @api
  get cvv() {
    return this._cvv;
  }

  /**
   * Gets or sets the expiry month of the card.
   *
   * The value of this property is updated in response to user interactions with the control.
   *
   * @type {String}
   */
  @api
  get expiryMonth() {
    return this._expiryMonth;
  }

  /**
   * Gets or sets the expiry year of the card.
   *
   * The value of this property is updated in response to user interactions with the control.
   *
   * @type {String}
   */
  @api
  get expiryYear() {
    return this._expiryYear;
  }

  /**
   * Checkout Settings
   * @type {Object}
   */
  @api
  get checkoutSettings() {
    return this._checkoutSettings;
  }

  set checkoutSettings(settings) {
    this._checkoutSettings = settings;
  }

  get labels() {
    return Constants.labels;
  }

  get feeTotal() {
    return this._feeTotal;
  }

  get showFeeText() {
    return this._showFeeText;
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

    const incompleteFields = this.hasIncompleteCardPaymentFields();

    const componentsToValidate =
      this.template.querySelectorAll("[data-validate]");

    // Need to run .reportValidity on all components to ensure that all errors are shown/cleared at once
    const validateFields = [...componentsToValidate].reduce(
      (result, component) => component.reportValidity() && result,
      true
    );

    return !incompleteFields && validateFields;
  }

  /**
   * Iterates through the credit card fields and checks if any of the fields that are displayed and are required have
   * an empty value. Sets an error on the cardAuthErrorMessage attribute if there is an empty required field.
   *
   * @returns true if there is an empty required field, false otherwise
   * @private
   */
  hasIncompleteCardPaymentFields() {
    const fieldRequiredValueMap = [
      {
        isRequiredAttr: true,
        value: this.cardHolderName,
        error: this.labels.InvalidName
      },
      {
        isRequiredAttr: true,
        value: this.cardNumber,
        error: this.labels.InvalidCreditCardNumber
      },
      {
        isRequiredAttr: true,
        value: this.cvv,
        error: this.labels.InvalidCvv
      },
      {
        isRequiredAttr: true,
        value: this.expiryMonth,
        error: this.labels.InvalidExpiryMonth
      },
      {
        isRequiredAttr: true,
        value: this.expiryYear,
        error: this.labels.InvalidExpiryYear
      },
      {
        isRequiredAttr: true,
        value: this.installments,
        error: this.labels.InvalidInstallments
      }
    ];

    const isInvalidField = fieldRequiredValueMap.find((field) => {
      return field.isRequiredAttr && !field.value;
    });

    return isInvalidField;
  }

  /**
   * Gets years to use in the Expiry Years dropdown
   *
   * @returns {Array} Years from current year to current year + 19
   * @private
   */
  get expiryYears() {
    const expiryYears = [],
      noOfYears = 20;

    let year, i;
    for (year = new Date().getFullYear(), i = 0; i < noOfYears; year++, i++) {
      expiryYears.push({ label: year, value: year.toString() });
    }
    return expiryYears;
  }

  /**
   * Gets months (as integers) to use in the Expiry Month dropdown
   *
   * @returns {Array} An array of integers from 1 - 12
   * @private
   */
  get expiryMonths() {
    const expiryMonths = [],
      noOfMonths = 12;

    for (let month = 1; month <= noOfMonths; month++) {
      expiryMonths.push({
        label: month < 10 ? `0${month}` : month,
        value: month.toString()
      });
    }
    return expiryMonths;
  }

  /**
   * Gets installments with installments according tax fees and other rules
   *
   * @returns {Array} An array of objects from 1 - 12 installments and labels
   * @private
   */
  get installments() {
    if (this._checkoutSettings) {
      const formatter = new Intl.NumberFormat("pt-BR", {
        style: "currency",
        currency: "BRL"
      });

      let installs = this._checkoutSettings.installments.map((installment) => {
        const installmentAmount = formatter.format(installment.per_install);
        const feeText = installment.fee ? "com juros*" : "sem juros";

        return {
          label: `${installment.install}x de ${installmentAmount} ${feeText}`,
          value: installment.install.toString()
        };
      });

      installs.unshift({
        label: "Selecione a quantidade de parcelas",
        value: ""
      });

      return installs;
    }

    return [];
  }

  /**
   * Gets SLDS classes to use for the Card Number field.  Dependent on if CVV field is hidden.
   *
   * @returns {string} SLDS classe ie. 'slds-size_2-of-3' if CVV visible
   * @private
   */
  get cardNumberClass() {
    const sldsColumnSize = this.hideCvv
      ? "slds-size_1-of-1"
      : "slds-size_2-of-3";
    return "slds-form-element " + sldsColumnSize;
  }

  /**
   * Handler for the when the Card Holder Name input is changed
   * @param {object} event change event
   *
   * @private
   */
  handleCardHolderNameChange(event) {
    this._cardHolderName = event.target.value;
    event.target.reportValidity();
  }

  /**
   * Handler for the when the Card Type input is changed
   * @param {object} event change event
   *
   * @private
   */
  handleCardTypeChange(event) {
    this._cardInstallments = event.target.value;
    event.target.reportValidity();
  }

  /**
   * Handler for the when the Card Number input is changed
   * @param {object} event change event
   *
   * @private
   */
  handleCardNumberChange(event) {
    const field = event.target;
    const cardNumber = field.value.replace(/ /g, "");

    this._cardNumber = field.value;

    if (!this.isValidCreditOrDebitCard(cardNumber)) {
      field.setCustomValidity("Por favor, informe um cartão válido.");
    }

    if (this.isValidCreditOrDebitCard(cardNumber)) {
      field.setCustomValidity("");
    }

    event.target.reportValidity();
  }

  /**
   * Handler for the when the CVV input is changed
   * @param {object} event change event
   *
   * @private
   */
  handleCvvChange(event) {
    this._cvv = event.target.value;
    event.target.reportValidity();
  }

  /**
   * Handler for the when the Expiry Month input is changed
   * @param {object} event change event
   *
   * @private
   */
  handleExpiryMonthChange(event) {
    this._expiryMonth = event.target.value;
    event.target.reportValidity();
  }

  /**
   * Handler for the when the Expiry Year input is changed
   * @param {object} event change event
   *
   * @private
   */
  handleExpiryYearChange(event) {
    this._expiryYear = event.target.value;
    event.target.reportValidity();
  }

  preventSensitiveInformationPropagation(keyboardEvent) {
    keyboardEvent.stopPropagation();
  }

  handleInstallmentsChange(event) {
    this._cardInstallments = event.target.value;

    if (!this._checkoutSettings) {
      return;
    }

    this._checkoutSettings.installments.forEach((installment) => {
      if (this._cardInstallments !== installment.install.toString()) {
        return;
      }

      if (installment.fee) {
        const formatter = new Intl.NumberFormat("pt-BR", {
          style: "currency",
          currency: "BRL"
        });

        this._feeTotal = formatter.format(installment.total);
        this._showFeeText = true;

        return;
      }

      this._feeTotal = "";
      this._showFeeText = false;
    });

    event.target.reportValidity();
  }

  isValidCreditOrDebitCard(cardNumber) {
    const checkCard = (function (arr) {
      return function (ccNum) {
        let len = ccNum.length,
          bit = 1,
          sum = 0,
          val;

        while (len) {
          val = parseInt(ccNum.charAt(--len), 10);
          sum += (bit ^= 1) ? arr[val] : val;
        }

        return sum && sum % 10 === 0;
      };
    })([0, 2, 4, 6, 8, 1, 3, 5, 7, 9]);

    return checkCard(cardNumber);
  }

  connectedCallback() {
    this._isConnected = true;
  }

  disconnectedCallback() {
    this._isConnected = false;
  }
}