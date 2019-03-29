// Turn img alt into caption
$('.content > p > img[alt]').replaceWith(function () {
    return '<figure>'
        + '<a href="' + $(this).attr('src') + '" class="mg-link">'
        + '<img src="' + $(this).attr('src') + '" width="' + $(this).attr('width') + '"/></a>'
        + '<figcaption class="caption">' + $(this).attr('alt') + '</figcaption>'
        + '</figure>';
});

// Connect magnific popup image viewer
$('.mg-link').magnificPopup({
    type: 'image',
    closeOnContentClick: true,
    closeBtnInside:false
});