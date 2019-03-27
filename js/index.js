/* global window */
(function (window, document, $) {
    'use strict';

        // turn img alt into caption
        $('.content > p > img[alt]').replaceWith(function () {
            return '<figure>'
                + '<a href="' + $(this).attr('src') + '" class="mg-link">'
                + '<img src="' + $(this).attr('src') + '"/></a>'
                + '<figcaption class="caption">' + $(this).attr('alt') + '</figcaption>'
                + '</figure>';
        });
        // and connect magnific popup image viewer
        $('#post-content .mg-link').magnificPopup({
            type: 'image',
            closeOnContentClick: true
        });
    });
}(window, window.document, window.jQuery));