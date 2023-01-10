window.onload = function () {

    //checks if element exists on screen and returns
    const checkElement = async selector => {
        while (document.querySelector(selector) === null) {
            await new Promise(resolve => requestAnimationFrame(resolve))
        }
        return document.querySelector(selector);
    };

    //check if the minicart exists
    checkElement('.cartItens')
        .then((selector) => {
            checkElement('#hiddenQuantity')
                .then((selector) => {
                    if (!$('#cartCount').length) {
                        //Add custom element that contains product count
                        $('.cartButton').append('<span id="cartCount" class="cartCount">' + $('#hiddenQuantity').val() + '</span>');
                    }

                    //Update cart count on cart change
                    $('#hiddenQuantity').on('change', function () {
                        $('#cartCount').text($(this).val());
                    });
                })

        });


    //Hover event in cart opens minicart 
    $('body').on('mouseover', '.cartButton', function () {
        setTimeout(() => {
            $(".updateCart").trigger('click');
        }, 2000);
        $('.cartItens').css('display', 'block');
    });

    // Mutations observes the body's class change
    (function ($) {
        var MutationObserver =
            window.MutationObserver ||
            window.WebKitMutationObserver ||
            window.MozMutationObserver;

        $.fn.attrchange = function (callback) {
            if (MutationObserver) {
                var options = {
                    subtree: false,
                    attributes: true
                };

                var observer = new MutationObserver(function (mutations) {
                    mutations.forEach(function (e) {
                        callback.call(e.target, e.attributeName);
                    });
                });

                return this.each(function () {
                    observer.observe(this, options);
                });
            }
        };
    })(jQuery);

    //custom class change events in the body
    $("body").attrchange(function (attrName) {
        //reloading the binds
        setTimeout(() => {

            //Update minicart on click of buttons on search result page 
            $('b2b_search_results-commerce-results').find('.slds-button_brand').on('click', function(){                       
                setTimeout(() => {
                    //Trigger click on update minicart button
                    $(".updateCart").trigger('click');
                    
                }, 3000);
            });
            
            //Update minicart on click of buttons on product page
            $("b2b_buyer_product_details-summary").find('.slds-button_brand').on('click', function(){                    
                setTimeout(() => {
                    //Trigger click on update minicart button
                    $(".updateCart").trigger('click');
                }, 3000);
                    
            }); 
            
            //Update minicart on click of increase and decrease buttons on cart page
            $(".cartContentsCmp").find('.controls').find('button').on('click', function(){                    
                setTimeout(() => {
                    //Trigger click on update minicart button
                    $(".updateCart").trigger('click');
                    
                }, 3000);
            });
                    
            //Update minicart on change of product count input on cart page
            $(".cartContentsCmp").find('.controls').find('input').on('change', function(){                    
                setTimeout(() => {
                    //Trigger click on update minicart button
                    $(".updateCart").trigger('click');
                }, 3000);
            });   
            
            //Update minicart if remove item on cart page
            $(".cartContentsCmp").find('.remove').on('click', function(){                    
                setTimeout(() => {
                    //Trigger click on update minicart button
                    $(".updateCart").trigger('click');
                }, 3000);
            });
                    
            $('b2b_buyer_wishlists-manager').find('.add-all-items-to-cart').find('b2b_buyer_cart-add-all-items-to-cart-button').on('click', function(){                    
                setTimeout(() => {
                    //Trigger click on update minicart button
                    $(".updateCart").trigger('click');
                }, 3000);
            }); 
                    
            //Update minicart if add items to cart on wish list page               
            $('b2b_buyer_wishlists-manager').find('.quantity-price-remove').find('b2b_buyer_cart-add-to-cart-button').on('click', function(){                    
                setTimeout(() => {
                    //Trigger click on update minicart button
                    $(".updateCart").trigger('click');
                }, 3000);
            });  
                    
            //Update minicart on click of increase and decrease buttons on product page        
            $('lb2bt-b2b-cross-sell').find('.slds-box').find('lightning-layout-item').find('.quantity-selector').find('lightning-button').on('click', function(){                    
                setTimeout(() => {
                    //Trigger click on update minicart button
                    $(".updateCart").trigger('click');
                }, 3000);
            });   

            //Update minicart if reorder on Order Summary page                
            $('b2b_buyer_orders-record-list').find('ul').find('.slds-m-bottom_medium').on('click', function(){                    
                setTimeout(() => {
                    //Trigger click on update minicart button
                    $(".updateCart").trigger('click');
                }, 3000);
            });      
            
            //Calculate the product discount in the result list
            $('b2b_search_results-commerce-results').find('.listing-price').each(function(){       
                console.log('this>>>', this)             
                setTimeout(() => {
                    console.log('executou o DISCOUNT')
                    var negotiatedPrice = parseFloat($(this).parent().parent().find('.negotiated-price').val()); 
                    var listingPrice = parseFloat($(this).val());
                    var calc = ((( negotiatedPrice - listingPrice) / listingPrice) * 100)  * -1; 

                    if(!$('.discount').length) {
                        $(this).parent().append('<span class="discount">'+calc.toString().split('.')[0]+'%</span>');                                                               
                    };
                }, 3000);
            });        

        }, 4000);


        // condition: if body class changes
        if (attrName == "class") {
            checkElement('#hiddenQuantity')
                .then((selector) => {
                    if (!$('#cartCount').length) {
                        //Add custom element that contains product count
                        $('.cartButton').append('<span id="cartCount" class="cartCount">' + $('#hiddenQuantity').val() + '</span>');
                    }

                    //Update cart count on cart change
                    $('#hiddenQuantity').on('change', function () {
                        $('#cartCount').text($(this).val());
                    });

                    $(".updateCart").trigger('click');
                })
        }
    });
}