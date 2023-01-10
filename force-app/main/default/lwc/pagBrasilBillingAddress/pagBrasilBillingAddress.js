/* eslint-disable @lwc/lwc/no-api-reassignments */
import { LightningElement, api } from "lwc";

import * as Constants from "./constants";
import * as States from "./states";
import * as Countries from "./countries";

import findAddressPostalCode from "@salesforce/apex/PagBrasilPaymentAddressController.findAddressPostalCode";
import getAccountAddresses from "@salesforce/apex/PagBrasilPaymentAddressController.getAccountAddresses";

/**
 * An event fired when the user's selected address has changed. This can occur even without user
 * interaction, since it defaults to the first result, meaning the user has essentially picked
 * that address unless they select another one.
 *
 * @event setbillingaddress
 * @type {CustomEvent}
 *
 * @property {Address} detail.address
 *   The address being changed to.
 *
 * @export
 */
const SET_BILLING_ADDRESS_EVENT = "setbillingaddress";

export default class PagBrasilBillingAddress extends LightningElement {
  @api isLoading = false;
  @api billingAddressHeader;

  _street;
  _number;
  _supplement;
  _neighborhood;
  _city;
  _state;
  _country = "BR";
  _postalCode;

  _address = "0";
  _accountAddress = [];

  get labels() {
    return Constants.labels;
  }

  get showFields() {
    return (
      (this._postalCode && this._postalCode.length === 9) ||
      this._address !== "0"
    );
  }

  get address() {
    return this._address;
  }

  get isNewAddress() {
    return this._address === "0";
  }

  get postalCode() {
    return this._postalCode;
  }

  get street() {
    return this._street;
  }

  get streetNumber() {
    return this._number;
  }

  get supplement() {
    return this._supplement;
  }

  get neighborhood() {
    return this._neighborhood;
  }

  get city() {
    return this._city;
  }

  get state() {
    return this._state;
  }

  get country() {
    return this._country;
  }

  get stateOptions() {
    return States.states.map((state) => {
      return {
        value: state.uf,
        label: state.label
      };
    });
  }

  get countryOptions() {
    return Countries.countries;
  }

  get addressOptions() {
    const defaultOption = {
      label: this.labels.NewAddressLabel,
      value: "0"
    };

    return [
      defaultOption,
      ...this._accountAddress.map((address) => {
        return {
          label: `${address.Address.street}, ${address.Address.city}, ${address.Address.state}, ${address.Address.postalCode}, ${address.Address.country}`,
          value: address.Id
        };
      })
    ];
  }

  hasIncompleteBillingAddressFields() {
    const fieldRequiredValueMap = [
      {
        isRequiredAttr: true,
        value: this.street,
        error: this.labels.InvalidStreet
      },
      {
        isRequiredAttr: true,
        value: this.streetNumber,
        error: this.labels.InvalidStreetNumber
      },
      {
        isRequiredAttr: true,
        value: this.neighborhood,
        error: this.labels.InvalidNeighborhood
      },
      {
        isRequiredAttr: true,
        value: this.city,
        error: this.labels.InvalidCity
      },
      {
        isRequiredAttr: true,
        value: this.state,
        error: this.labels.InvalidState
      },
      {
        isRequiredAttr: true,
        value: this.country,
        error: this.labels.InvalidCountry
      }
    ];

    const isInvalidField = fieldRequiredValueMap.find((field) => {
      return field.isRequiredAttr && !field.value;
    });

    return isInvalidField;
  }

  @api
  reportValidity() {
    const incompleteFields = this.hasIncompleteBillingAddressFields();

    const componentsToValidate =
      this.template.querySelectorAll("[data-validate]");

    const validateFields = [...componentsToValidate].reduce(
      (result, component) => component.reportValidity() && result,
      true
    );

    return !incompleteFields && validateFields;
  }

  handleAddressChange(event) {
    this._address = event.target.value;

    if (this._address === "0") {
      this.clearAddress();
    }

    const foundAddress = this._accountAddress.filter((address) => {
      return address.Id === this._address;
    });

    if (foundAddress.length) {
      const selectedAddress = foundAddress[0].Address;

      this._city = selectedAddress.city;
      this._state = selectedAddress.state;
      this._postalCode = selectedAddress.postalCode;

      const addressComponents = selectedAddress.street.split(" - ");
      if (addressComponents.length !== 3) {
        const fakeKeyboardEvent = {
          target: {
            value: this._postalCode
          }
        };
        this.formatPostalCode(fakeKeyboardEvent);
        return;
      }

      const streetComponents = addressComponents[0].split(", ");

      this._street = streetComponents[0];
      this._number = streetComponents[1];

      this._supplement = addressComponents[1];
      this._neighborhood = addressComponents[2].replace("Bairro ", "");

      this.dispatchEvent(
        new CustomEvent(SET_BILLING_ADDRESS_EVENT, {
          detail: {
            address: Object.assign({}, foundAddress[0])
          }
        })
      );
    }
  }

  handleAddressFieldsChange() {
    this.dispatchEvent(
      new CustomEvent(SET_BILLING_ADDRESS_EVENT, {
        detail: {
          address: {
            street: this._street,
            number: this._number,
            supplement: this._supplement,
            neighborhood: this._neighborhood,
            city: this._city,
            state: this._state,
            country: this._country,
            postalCode: this._postalCode
          }
        }
      })
    );
  }

  handleAddressStreetFieldChange(event) {
    this._street = event.target.value;
    this.handleAddressFieldsChange();
  }

  handleAddressStreetNumberFieldChange(event) {
    this._number = event.target.value;
    this.handleAddressFieldsChange();
  }

  handleAddressSupplementFieldChange(event) {
    this._supplement = event.target.value;
    this.handleAddressFieldsChange();
  }

  handleAddressNeightborhoodFieldChange(event) {
    this._neighborhood = event.target.value;
    this.handleAddressFieldsChange();
  }

  handleAddressCityFieldChange(event) {
    this._city = event.target.value;
    this.handleAddressFieldsChange();
  }

  handlePostalCodeChange(event) {
    this._postalCode = event.target.value;

    if (this._postalCode.length !== 9) {
      return;
    }

    this.isLoading = true;

    findAddressPostalCode({
      postalCode: this._postalCode
    })
      .then((response) => {
        const fullAddress = JSON.parse(response);

        this._street = fullAddress.logradouro;
        this._neighborhood = fullAddress.bairro;
        this._city = fullAddress.localidade;
        this._state = fullAddress.uf;

        this.isLoading = false;
      })
      .catch((err) => console.error(err));

    this.handleAddressFieldsChange();
  }

  formatPostalCode(keyboardEvent) {
    keyboardEvent.target.value = keyboardEvent.target.value
      .replace(/\D/g, "")
      .replace(/(\d{5})(\d{1,3})$/g, "$1-$2");

    this.handlePostalCodeChange(keyboardEvent);
  }

  clearAddress() {
    this._city = "";
    this._state = "";
    this._postalCode = "";
    this._street = "";
    this._number = "";
    this._supplement = "";
    this._neighborhood = "";
  }

  connectedCallback() {
    getAccountAddresses()
      .then((response) => {
        if (response.length) {
          this._accountAddress = response;
        }
      })
      .catch((error) => console.error(error));
  }
}