$(function() {
  // スクロールトップ
  $(window).scroll(function() {
    let scroll = $(this).scrollTop();
    let elements = $('.scrolltop, .toclist, .refine, .sns');
    if(scroll > 300) {
      elements.fadeIn();
    } else {
      elements.fadeOut();
    }
  });
  $('.scrolltop').click(function() {
    $('html,body').animate({
      scrollTop: 0
    }, 500);
    return false;
  });
  // トップページ大会情報、大会結果スライダー
  $('.slick-result,.slick-compe').slick({
    autoplay: true,
    arrows: false,
    centerMode: true,
    variableWidth: true,
  });
});